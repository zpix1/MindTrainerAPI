require 'sinatra'
get '/' do
    @task = {}
    @task[:answer] = 123
    erb :'digsum_check.html', layout: :'layout.html'
end