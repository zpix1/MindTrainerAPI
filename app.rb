require 'sinatra' # Сервер
require 'json' # Парсинг JSON
require 'byebug'
require 'open3'
enable :sessions # Включаем cookies


get '/' do # На show
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
    rescue JSON::ParserError
        @error = { code: status, stdout: ans, stderr: stderr }
        erb :'error.html'
    else
        @task['question'] = result['question'] # Раскладываем
        @task['answer'] = result['answer']

        session[:task] = JSON.generate @task # Запоминаем задачу
        erb :'../trainer/show.html', layout: :'layout.html' # Показываем страницу
    end
end

post '/check' do # на check
    app_config = JSON.parse(open('config.json').read())

    @task = JSON.parse session[:task] # Получаем сохраненную задачу
    @task['mode'] = 'check'
    @task['user_answer'] = params['user_answer']
    cmd = "cd trainer; #{app_config['command']} #{JSON.generate(@task)}" # Строка для проверки
    
    ans = `#{cmd}`
    if ans.chomp == 'false' # Если юзер ошибся
        erb :'../trainer/check.html', layout: :'layout.html' # Показываем страницу с правильным ответом
    else
        redirect to('/') # Следующая задача
    end
end