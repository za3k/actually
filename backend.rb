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
        
    end

	get '/status/:task' do
		{
            percentDone: rand(0..100),
            status: ["done", "notstarted", "error", "paused", "active", "retry-active", "invalid"].sample
        }.to_json
	end
end
