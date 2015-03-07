require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/formkeeper'

set :port, 3765
set :public_folder, File.dirname(__FILE__) + '/static'
enable :sessions
set :session_secret, '48fa3729hf0219f'