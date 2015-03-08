require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/formkeeper'
require 'json'

require_relative 'models/user'
require_relative 'models/tweet'

set :port, 3765
set :public_folder, File.dirname(__FILE__) + '/static'
enable :sessions
set :session_secret, '48fa3729hf0219f'

get '/' do
  tweets = Tweet.all
  if session[:user] # If user has credentials saved in session cookie (is logged in)
    erb :logged_root, :locals => { :user => session[:user], :tweets => tweets }
  else
    erb :root, :locals => { :tweets => tweets }
  end
end

get '/logout' do
  tweets = Tweet.all
  erb :root, :locals => { :tweets => tweets, :logout => true }
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
    # Using form[param] instead of params[param] passes parameters filtered through :filter rules
    user = User.create(name: form[:name],
                       email: form[:email],
                       username: form[:username],
                       password: form[:password],
                       phone: form[:phone])
    if user.valid?
      session[:user] = user
      user.to_json
      redirect to '/'
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
    user = User.find_by_username_and_password params[:username], params[:password]
    if user
      session[:user] = user
      redirect to '/'
      user.to_json
    else
      redirect to '/', :locals
      error 400, { :error => 'invalid login credentials' }.to_json
    end
  rescue => e
    error 400, e.message.to_json
  end
end

# logout and delete session cookie
get '/nanotwitter/v1.0/logout' do
  session[:user] = nil
  redirect to '/logout'
end