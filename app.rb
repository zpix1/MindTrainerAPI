require 'sinatra'
require 'json'
require 'byebug'
require 'open3'
enable :sessions

# Этот код писался на коленке за несколько дней до сборов.


def check_all
    files = ['config.json','show.html.erb','check.html.erb']
    files.each do |f|
        unless File.file?("trainer/#{f}")
            @error = { file: f, type: 'files'}
            erb :'error.html'
            return @error
        end
    end
    begin
        app_config = JSON.parse(open('trainer/config.json').read())
    rescue
        @error = { type: 'config_error', json: app_config}
        return erb :'error.html'
    end
    keys = ['command','config_template']
    keys.each do |k|
        unless app_config.has_key?(k)
            @error = { type: 'config_error', json: JSON.pretty_generate(app_config)}
            return erb :'error.html'
        end
    end
    return false
end


def get_saves(config_template)
    saves = { 'seed'=> rand(10000000).to_s, 'config'=> config_template.map{|p|[p['nick'],0]}.to_h }
    if File.file?("data/saves.json")
        saves = JSON.parse(open("data/saves.json").read)
    end
    return saves
end

get '/' do
    if cf = check_all()
        return erb :'error.html'
    end
    app_config = JSON.parse(open('trainer/config.json').read())

    @task = {}

    saves = get_saves(app_config['config_template'])

    @task['config'] = saves['config']
    @task['seed'] = rand(1..10000).to_s

    @task['mode'] = 'generate'
    cmd = "cd trainer; #{app_config['command']} '#{JSON.generate(@task)}'"
    print(cmd)
    ans, stderr, status = Open3.capture3(cmd)

    begin
        result = JSON.parse(ans)
    rescue
        @error = { code: status, stdout: ans, stderr: stderr , cmd: cmd, type: 'trainer'}
        return erb :'error.html'
    end

    unless result.has_key?('question') and result.has_key?('answer')
        @error = { type: 'json_error', json: ans}
        return erb :'error.html'
    end

    @task['question'] = result['question']
    @task['answer'] = result['answer']

    session[:task] = JSON.generate @task
    erb :'../trainer/show.html', layout: :'layout.html'
end

post '/check' do # на check
    check_all()
    app_config = JSON.parse(open('trainer/config.json').read())
    if session[:task].nil?
        @error = {type: 'session'}
        return erb :'error.html'
    end
    @task = JSON.parse session[:task]
    @task['mode'] = 'check'
    @task['user_answer'] = params['user_answer']
    cmd = "cd trainer; #{app_config['command']} '#{JSON.generate(@task)}'"


    ans, stderr, status = Open3.capture3(cmd)
    begin
        result = JSON.parse ans
    rescue
        @error = { code: status, stdout: ans, stderr: stderr, cmd: cmd, type: 'trainer'}
        erb :'error.html'
    else
        if ans.chomp == 'false'
            erb :'../trainer/check.html', layout: :'layout.html'
        else
            redirect to('/')
        end
    end
    # end
end

get '/settings' do
    check_all()
    app_config = JSON.parse(open('trainer/config.json').read())
    saves = get_saves(app_config['config_template'])
    @pars = app_config['config_template'].map{|p|trainer_param(p,saves['config'])}
    # open("data/saves.json",'w').write(JSON.pretty_generate(saves))
    erb :'settings.html'
end


post '/settings' do
    check_all()
    app_config = JSON.parse(open('trainer/config.json').read())
    saves = get_saves(app_config['config_template'])

    # byebug
    params['config'].each do |k,v|
        saves['config'][k] = v
    end
    @pars = app_config['config_template'].map{|p|trainer_param(p,saves['config'])}
    @done = true
    f = open("data/saves.json",'w');f.write(JSON.pretty_generate(saves));f.close
    erb :'settings.html'
end

def trainer_param(param, config)
    param_nick = param['nick']
    param_type = param['type']
    # byebug
    ans = "<label>#{param['description']}</label>"
    if param_type == 'int'
      ans += "<input type='number' name='config[#{param_nick}]' value='#{config[param_nick]}' min=#{param['min']} max=#{param['max']}></input>"

    # # byebug
    # elsif param_type == 'string'
    #   ans += text_field_tag("config[#{param_nick}]", config[param_nick], class: 'trainer_param')
    # elsif param_type == 'bool'
    #   ans += checkbox_tag("config[#{param_nick}]", config[param_nick], class: 'trainer_param')
    elsif param_type == 'select'
      ans += "<select name=config[#{param_nick}]>"
      ans += param['options'].map{|e| e['nick'] != config[param_nick] ? "<option value='#{e["nick"]}'>#{e["name"]}</option>" : "<option selected value='#{e["nick"]}'>#{e["name"]}</option>"}.join
      ans += "</select>"
      # ans += select("config","#{param_nick}", param['options'].map{|e| [e["name"],e["nick"]]}, {class: 'trainer_param', selected: config[param_nick]}, class: 'trainer_param')
    end
    # elsif param_type == 'int_table'
    #   height = param[:height]
    #   width = param[:width]

    #   ans += "<table id='#{param_nick}' class='trainer_param'>".html_safe
    #   height.times do |i|
    #     ans += '<tr>'.html_safe
    #     width.times do |j|
    #       ans += '<td>'.html_safe
    #       if config[param_nick]
    #         ans += number_field_tag("config[#{param_nick}][#{i}#{j}]", config[param_nick][i][j], min: param['min'], max: param[:max])
    #       else
    #         ans += number_field_tag("config[#{param_nick}][#{i}#{j}]", 0, min: param[:min], max: param[:max])
    #       end
    #       ans += '</td>'.html_safe
    #     end
    #     ans += '</tr>'.html_safe
    #   end
    #   ans += '</table>'.html_safe
    # end

    # byebug
    ans
  end