require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/formkeeper'
require 'json'

require_relative 'models/user'

set :port, 3765
set :public_folder, File.dirname(__FILE__) + '/static'
enable :sessions
set :session_secret, '48fa3729hf0219f'

get '/' do
  if session[:user]
    erb :logged_root, :locals => { :user => session[:user] }
  else
    erb :root
  end
end

# get a user by name
get '/nanotwitter/v1.0/users/:name' do
  user = User.find_by_name params[:name]
  if user
    user.to_json
  else
    error 404, { :error => 'user not found' }.to_json
  end
end

# create a new user
post '/nanotwitter/v1.0/users' do
  begin
    user = User.create JSON.parse request.body.read
    if user.valid?
      user.to_json
    else
      error 400, user.errors.to_json
    end
  rescue => e
    error 400, e.message.to_json
  end
end

# update an existing user
put '/nanotwitter/v1.0/users/:name' do
  user = User.find_by_name params[:name]
  if user
    begin
      if user.update_attributes JSON.parse request.body.read
        user.to_json
      else
        error 400, user.errors.to_json
      end
    rescue => e
      error 400, e.message.to_json
    end
  else
    error 404, { :error => 'user not found' }.to_json
  end
end

# destroy an existing user
delete '/nanotwitter/v1.0/users/:name' do
  user = User.find_by_name params[:name]
  if user
    user.destroy
    user.to_json
  else
    error 404, { :error => 'user not found' }.to_json
  end
end

# verify a user name and password
post '/nanotwitter/v1.0/users/session' do
  begin
    user = User.find_by_name_and_password params[:name], params[:password]
    if user
      session[:user] = user
      user.to_json
    else
      error 400, { :error => 'invalid login credentials' }.to_json
    end
  rescue => e
    error 400, e.message.to_json
  end
end