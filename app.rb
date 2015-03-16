require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/formkeeper'
require 'json'

require_relative 'user_service'
require_relative 'tweet_service'
require_relative 'models/follow'

set :port, 3765
set :public_folder, File.dirname(__FILE__) + '/static'
enable :sessions
set :session_secret, '48fa3729hf0219f4rfbf39hf231b313fb3f723bf8287dadk54'

get '/' do
  # Verify cookie contains current data.
  if session[:user]
    # If cookie is out of date, delete it.
    user = UserService.get_by_id session[:user][:id]
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

    tweets = TweetService.tweets_by_user_id followees

    erb :logged_root, :locals => { :user => session[:user], :tweets => tweets }
  elsif session[:login_error]
    tweets = TweetService.tweets

    login_error = session[:login_error]
    session[:login_error] = nil

    erb :root, :locals => { :tweets => tweets, :login_error => login_error }
  else
    tweets = TweetService.tweets

    erb :root, :locals => { :tweets => tweets }
  end
end

get '/logout' do
  tweets = TweetService.tweets

  erb :root, :locals => { :tweets => tweets, :logout => true }
end

# logout and delete session cookie
get '/nanotwitter/v1.0/logout' do
  session[:user] = nil
  redirect to '/logout'
end

get '/nanotwitter/v1.0/users/:username' do
  user = UserService.get_by_username params[:username]

  tweets = TweetService.tweets_by_user_id user[:id]

  if session[:user]
    if session[:user][:username] == user[:username]
      erb :user_page, :locals => { :user => user, :tweets => tweets }
    elsif user
      erb :profile_page,  :locals => { :user => session[:user], :profile_user => user, :tweets => tweets }
    else
      error 404, { :error => 'user not found' }.to_json
    end
  elsif user
    erb :profile_page,  :locals => { :profile_user => user, :tweets => tweets }
  end

end

# Get a user by table id
get '/nanotwitter/v1.0/users/id/:id' do
  user = UserService.get_by_id params[:id]
  redirect to "/nanotwitter/v1.0/users/#{user[:username]}"
end

get '/nanotwitter/v1.0/users/profile' do
  if session[:user] # If user has credentials saved in session cookie (is logged in)
    followees = Follow.where follower_id: session[:user][:id]
    erb :profile, :locals => { :user => session[:user], :followees => followees }
  else
    redirect to '/'
  end
end

# create a new user
post '/nanotwitter/v1.0/users' do
    user = UserService.new(name: params[:name],
                       email: params[:email],
                       username: params[:username],
                       password: params[:password],
                       phone: params[:phone])
    if user
      session[:user] = user
      redirect back
    else
      error 400, user.errors.to_json
    end
end

post '/nanotwitter/v1.0/users/id/:id/tweet' do
    TweetService.new({ text: params[:tweet],
                user_id: params[:id]
              })
    redirect back
end

# verify a user name and password
post '/nanotwitter/v1.0/users/session' do
  user = UserService.get_by_username_and_password({ :username => params[:username], :password => params[:password] })
  if user
    session[:user] = user
  else
    session[:login_error] = { :error_codes => [1], :message => 'Account credentials are invalid.' }
  end
  redirect to '/'
end

# update an existing user by table id
put '/nanotwitter/v1.0/users/id/:id' do
  user = UserService.get_by_id params[:id]
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

# udpate an existing user using follow functions.
post '/nanotwitter/v1.0/users/:username/follow' do
  followee = User.find_by_username params[:username]
  session[:user].followees << followee
  redirect back
end 
  
# logout and delete session cookie
delete '/nanotwitter/v1.0/logout' do
  session[:user] = nil
  redirect to '/logout'
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
