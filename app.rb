require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/formkeeper'
require 'json'

require_relative 'models/user'
require_relative 'models/tweet'
require_relative 'models/follow'

set :port, 3765
set :public_folder, File.dirname(__FILE__) + '/static'
enable :sessions
set :session_secret, '48fa3729hf0219f4rfbf39hf231b313fb3f723bf8287dadk54'


get '/nanotwitter/v1.0/users/profile' do
  if session[:user] # If user has credentials saved in session cookie (is logged in)
    followees = Follow.where follower_id: session[:user][:id]
    erb :profile, :locals => { :user => session[:user], :followees => followees }
   else
    redirect to '/'
  end
end



get '/' do
  # Verify cookie contains current data.
  if session[:user]
    # If cookie is out of date, delete it.
    user = User.find_by_id session[:user][:id]
    if user
      unless session[:user][:updated_at] == user[:updated_at]
        session.clear
      end
    else
      session.clear
    end
  end

  if session[:user] # If user has credentials saved in session cookie (is logged in)
    users_to_follow = session[:user].followees
    followees = users_to_follow.collect { |user| user[:id] }
    followees.push session[:user][:id] # you should see your own tweets as well

    tweets = Tweet.where(user_id: followees).limit(25).order created_at: :desc
    full_tweets = []
    tweets.each do |tweet|
      user = User.find_by_id tweet[:user_id]
      full_tweets.push [tweet, user]
    end
    erb :logged_root, :locals => { :user => session[:user], :tweets => full_tweets }
  else
      tweets = Tweet.limit(25).order created_at: :desc
      full_tweets = []
      tweets.each do |tweet|
        user = User.find_by_id tweet[:user_id]
        full_tweets.push [tweet, user]
      end
    erb :root, :locals => { :tweets => full_tweets }
  end
end

get '/logout' do
  tweets = Tweet.limit(25).order created_at: :desc
  full_tweets = []
  tweets.each do |tweet|
    user = User.find_by id: tweet[:user_id]
    full_tweets.push [tweet, user]
  end
  erb :root, :locals => { :tweets => full_tweets, :logout => true }
end

# logout and delete session cookie
get '/nanotwitter/v1.0/logout' do
  session[:user] = nil
  redirect to '/logout'
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

# get a user by table id
get '/nanotwitter/v1.0/users/id/:id' do
  user = User.find_by_id params[:id]
  if user
    user.to_json
  else
    error 404, { :error => 'user not found' }.to_json
  end
end

# create a new user
post '/nanotwitter/v1.0/users' do
  begin
    user = User.create(name: params[:name],
                       email: params[:email],
                       username: params[:username],
                       password: params[:password],
                       phone: params[:phone])
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

post '/nanotwitter/v1.0/tweets' do
  begin
    tweet = Tweet.create( text: params[:tweet],
                          user_id: session[:user]['id'])
    if tweet.valid?
      tweet.to_json
      redirect to request.script_name # should return to page POST was called from
    else
      error 400, tweet.errors.to_json
    end
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

# update an existing user by table id
put '/nanotwitter/v1.0/users/:id' do
  user = User.find_by_id params[:id]
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
# delete '/nanotwitter/v1.0/users/:name' do
#   user = User.find_by_name params[:name]
#   if user
#     user.destroy
#     user.to_json
#   else
#     error 404, { :error => 'user not found' }.to_json
#   end
# end