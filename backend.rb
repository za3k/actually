require 'rubygems'
require 'sinatra'
require "sinatra/reloader" #if development?
require 'json'

class Backend < Sinatra::Base
    configure :development do
        register Sinatra::Reloader
    end
    configure do
    	set :public_folder, '.' #File.dirname(__FILE__) + '/../'
    end

    get '/' do
        redirect "/tasks"
    end

    get '/tasks' do
        # Right now we show ongoing tasks -- dervivation followed by derive tasks underneath
        send_file File.expand_path('html/tasks.html', settings.public_folder)
    end

    TASK_TIME = 10
    STATUSES = ["done", "notstarted", "error", "paused", "active", "retry-active", "invalid"]
	get '/api/tasks/:task/status' do
        time = Time.now.to_i
        task_id = params['task'].to_i
		{
            percentDone: ((time % TASK_TIME).to_f / TASK_TIME * 100).to_i, # rand(0..100),
            status: STATUSES[(time.div(TASK_TIME) + task_id) % STATUSES.length],
        }.to_json
	end
    
    get '/api/tasks' do
        time = Time.now.to_i
        (1..10).to_a.select{ |num| time.div(TASK_TIME) % num == 0 }.to_json
    end

    get '/api/tasks/:task_id' do

    end

    post '/api/tasks' do

    end

    put '/api/tasks/:task_id' do

    end
end
