require 'sinatra' # Сервер
require 'json' # Парсинг JSON
require 'byebug'
require 'open3'
enable :sessions # Включаем cookies

# Смотрим файлы
def checkfiles
    
    files = ['config.json','show.html.erb','check.html.erb']
    files.each do |f|
        unless File.file?("trainer/#{f}")
            @error = { file: f, type: 'files'}
            erb :'error.html'
            return @error
        end
    end
    return false
end

get '/' do # На show
    if cf = checkfiles()
        return erb :'error.html'
    end
    app_config = JSON.parse(open('trainer/config.json').read())

    @task = {} # Задаем сид и конфиг задачи
    @task['config'] = app_config["config"]
    @task['seed'] = rand(1..10000)
    # Генерируем строку для запуска
    @task['mode'] = 'generate'
    cmd = "cd trainer; #{app_config['command']} '#{JSON.generate(@task)}'"
    print(cmd)
    # byebug
    ans, stderr, status = Open3.capture3(cmd)
    # byebug
    # ans = `#{cmd}` # Получаем ответ
    begin
        result = JSON.parse ans # Парсим его
    rescue
        @error = { code: status, stdout: ans, stderr: stderr , cmd: cmd, type: 'trainer'}
        return erb :'error.html'
    end
    @task['question'] = result['question'] # Раскладываем
    @task['answer'] = result['answer']

    session[:task] = JSON.generate @task # Запоминаем задачу
    erb :'../trainer/show.html', layout: :'layout.html' # Показываем страницу
end

post '/check' do # на check
    checkfiles()
    app_config = JSON.parse(open('trainer/config.json').read())
    if session[:task].nil?
        @error = {type: 'session'}
        return erb :'error.html'
    end
    @task = JSON.parse session[:task] # Получаем сохраненную задачу
    @task['mode'] = 'check'
    @task['user_answer'] = params['user_answer']
    cmd = "cd trainer; #{app_config['command']} '#{JSON.generate(@task)}'" # Строка для проверки
    # byebug
    puts cmd

    ans, stderr, status = Open3.capture3(cmd)
    begin
        result = JSON.parse ans # Парсим его
    rescue
        @error = { code: status, stdout: ans, stderr: stderr, cmd: cmd, type: 'trainer'}
        erb :'error.html'
    else
        if ans.chomp == 'false' # Если юзер ошибся
            erb :'../trainer/check.html', layout: :'layout.html' # Показываем страницу с правильным ответом
        else
            redirect to('/') # Следующая задача
        end
    end
    # end
end