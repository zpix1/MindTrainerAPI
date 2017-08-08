require 'sinatra' # Сервер
require 'json' # Парсинг JSON
require 'byebug'
enable :sessions # Включаем cookies

PROGRAM = 'python task.py' # Измените на свою

get '/' do # На show
    app_config = JSON.parse(open('config.json').read())

    @task = {} # Задаем сид и конфиг задачи
    @task['config'] = app_config["config"]
    @task['seed'] = rand(1..10000)
    # Генерируем строку для запуска
    cmd = "#{app_config['command']} generate '#{JSON.generate(@task['config'])}' '#{@task['seed'] % 30000}'"
    byebug
    ans = `#{cmd}` # Получаем ответ
    result = JSON.parse ans # Парсим его

    @task['question'] = result['question'] # Раскладываем
    @task['answer'] = result['answer']

    session[:task] = JSON.generate @task # Запоминаем задачу
    erb :'show.html', layout: :'layout.html' # Показываем страницу
end

post '/check' do # на check
    app_config = JSON.parse(open('config.json').read())

    @task = JSON.parse session[:task] # Получаем сохраненную задачу

    cmd = "#{app_config['command']} check '#{params['user_answer']}' '#{@task['answer']}' '#{@task['seed'] % 30000}'" # Строка для проверки
    
    ans = `#{cmd}`
    if ans.chomp == 'false' # Если юзер ошибся
        erb :'check.html', layout: :'layout.html' # Показываем страницу с правильным ответом
    else
        redirect to('/') # Следующая задача
    end
end