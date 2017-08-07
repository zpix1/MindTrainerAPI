require 'sinatra' # Сервер
require 'json' # Парсинг JSON
enable :sessions # Включаем cookies

get '/' do # На show
    @task = {} # Задаем сид и конфиг задачи
    @task['config'] = {'maxval': 5} 
    @task['seed'] = rand(1..10000)
    # Генерируем строку для запуска
    cmd = "timeout 2 python task.py generate '#{JSON.generate(@task['config'])}' '#{@task['seed'] % 30000}'" 
    ans = `#{cmd}` # Получаем ответ
    result = JSON.parse ans # Парсим его

    @task['question'] = result['question'] # Раскладываем
    @task['answer'] = result['answer']

    session[:task] = JSON.generate @task # Запоминаем задачу
    erb :'show.html', layout: :'layout.html' # Показываем страницу
end

post '/check' do # на check
    @task = JSON.parse session[:task] # Получаем сохраненную задачу
    cmd = "timeout 2 python task.py check '#{params['user_answer']}' '#{@task['answer']}' '#{@task['seed'] % 30000}'" # Строка для проверки
    ans = `#{cmd}`
    if ans.chomp == 'false' # Если юзер ошибся
        erb :'check.html', layout: :'layout.html' # Показываем страницу с правильным ответом
    else
        redirect to('/') # Следующая задача
    end
end