require 'sinatra'
require 'tilt/erb'
# require 'newrelic_rpm'
require 'sinatra/activerecord'
require 'sinatra/formkeeper'
require 'faker'
require 'redis'

require_rel 'services/*', 'models/follow'

# Configure server environment
configure do

  env = ENV['SINATRA_ENV'] || 'development'
  databases = YAML.load(ERB.new(File.read('config/database.yml')).result)
  ActiveRecord::Base.establish_connection databases[env]

  set :port, 3765
  set :public_folder, File.dirname(__FILE__) + '/static'
  enable :sessions
  set :session_secret, '48fa3729hf0219f4rfbf39hf2'

  $redis = Redis.new(
      :host => 'pub-redis-13514.us-east-1-3.2.ec2.garantiadata.com',
      :port => '13514',
      :password => 'nanotwitter'
  )

end

# for load testing with Loader.io
get '/loaderio-7b84b69492913d259b5266ab9f52dea7/' do
  send_file File.new 'loaderio-7b84b69492913d259b5266ab9f52dea7.txt'
end

# for Pito's load testing
get '/loaderio-7075d4380f6f2dacc9025ebdc486490d/' do
	send_file File.new 'loaderio-7075d4380f6f2dacc9025ebdc486490d.txt'
end

get '/' do
  # Verify cookie contains current data.
  if session[:user]
    # If cookie is out of date, delete it.
    user = UserService.get_by_id session[:user]
    unless user
      session.clear
    end
  end

  if session[:user] # If user has credentials saved in session cookie (is logged in)
    erb :logged_root, :locals => { :user => user }

  elsif session[:login_error] # if user entered invalid login credentials
    login_error = session[:login_error]
    session[:login_error] = nil
    erb :root, :locals => { :login_error => login_error }

  elsif session[:reg_error] # if user encountered an error during account registration
    reg_error = session[:reg_error]
    session[:reg_error] = nil
    erb :root, :locals => { :reg_error => reg_error }
  else
    erb :root
  end
end

get '/logout' do
  redirect to '/nanotwitter/v1.0/logout' unless session[:user].nil?

  erb :root, :locals => { :logout => true }
end

# logout and delete session cookie
get '/nanotwitter/v1.0/logout' do
  session[:user] = nil
  redirect to '/logout'
end

# get latest tweets
get '/nanotwitter/v1.0/tweets' do
  tweets = TweetService.tweets $redis
  erb :feed_tweets, :locals => { tweets: tweets }, :layout => false
end

# get latest tweets from followees of logged in user
get '/nanotwitter/v1.0/tweets/followees' do
  if session[:user]
    user = UserService.get_by_id session[:user]
    users_to_follow = user.followees
    followees = users_to_follow.collect { |u| u[:id] }
    followees.push user[:id] # you should see your own tweets as well

    tweets = TweetService.tweets_by_user_id followees
    erb :feed_tweets, :locals => { :tweets => tweets }, :layout => false
  else
    erb :feed_tweets, :locals => {:tweets => [] }, :layout => false
  end
end

get '/nanotwitter/v1.0/users/:username' do

  redirect to '/test_user' if params[:username] == 'test_user'

  user = UserService.get_by_username params[:username]

  tweets = TweetService.tweets_by_user_id user[:id]

  if session[:user]
    logged_in_user = UserService.get_by_id session[:user]
    if user && logged_in_user
      erb :user_page, :locals => { :user => logged_in_user, :profile_user => user, :tweets => tweets }
    else
      error 404, { :error => 'user not found' }.to_json
    end
  elsif user
    erb :user_page,  :locals => { :profile_user => user, :tweets => tweets }
  else
    error 404, { :error => 'user not found' }.to_json
  end

end

# Get a user by table id
get '/nanotwitter/v1.0/users/id/:id' do
  user = UserService.get_by_id params[:id]
  redirect to "/nanotwitter/v1.0/users/#{user[:username]}"
end

get '/nanotwitter/v1.0/users/:username/profile' do
  if session[:user] # If user has credentials saved in session cookie (is logged in)
    logged_in_user = UserService.get_by_id session[:user]
    user = UserService.get_by_username params[:username]
    if logged_in_user[:username] == user[:username] # if user is requesting their own page
      followees = Follow.where follower_id: logged_in_user[:id]
      users = []
      followees.each do |user| 
        users.push UserService.get_by_id user[:followee_id]
      end
      erb :user_profile, :locals => { :user => logged_in_user, :users => users }
    else
      error 403, { :error=> 'forbidden from accessing this page' }.to_json # forbidden from accessing this page
    end
  else
    error 401, { :error => 'must be logged in to access' }.to_json # must be logged in to access
  end
end

# create a new user
post '/nanotwitter/v1.0/users' do

  form do # Cannot be pulled out into a service due to requirement of formkeeper gem
    filters :strip
    field :name, :present => true, :alpha_space => true
    field :email, :present => true, :email => true
    field :username, :present => true, :ascii => true, :length => 3..20
    field :password, :present => true, :ascii => true, :length => 8..30
    field :password2, :present => true, :ascii => true, :length => 8..30
    same :same_password, [:password, :password2]
    field :phone, :present => true, :int => true, :length => 10
  end

  failures = FormService.validate_registration form

  if failures
    session[:reg_error] = failures[:reg_error]
    redirect to '/'
  else
    user = UserService.new(name: form[:name],
                           email: form[:email],
                           username: form[:username],
                           password: form[:password],
                           phone: form[:phone])
    if user
      session[:user] = user[:id]
      redirect to '/'
    else
      error 400, user.errors.to_json
    end
  end
end

# search database for user
post '/nanotwitter/v1.0/users/search' do
  if params[:search].length == 0
    redirect back
  else
    form do # cannot be pulled out into a service due to requirement of formkeeper gem
      filters :strip
      field :search, :present => true
    end

    search_terms = form[:search]
    users = UserService.search_for search_terms
    erb :search_results, :locals => { results: users, search_term: search_terms }
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
    session[:user] = user[:id]
  else
    session[:login_error] = { :error_codes => ['l-inv'], :message => 'Account credentials are invalid.' }
  end
  redirect to '/'
end

# add a followee to a user.
post '/nanotwitter/v1.0/users/:username/follow' do
  if session[:user]
    logged_in_user = UserService.get_by_id session[:user]
    followee = UserService.get_by_username params[:username]

    logged_in_user.follow followee
    redirect back
  else
    error 401, { :error => 'must be logged in to access' }.to_json # must be logged in to access
  end
end

# remove a followee from a user.
post '/nanotwitter/v1.0/users/:username/unfollow' do
  if session[:user]
    logged_in_user = UserService.get_by_id session[:user]
    followee = UserService.get_by_username params[:username]
    logged_in_user.unfollow followee
    redirect back
  else
    error 401, { :error => 'must be logged in to access' }.to_json # must be logged in to access
  end
end

get '/test_tweet' do 
  LoadTestService.test_tweet
end

get '/test_follow' do
  LoadTestService.test_follow
end

get 'test_user' do
  test_user = UserService.get_by_username 'test_user'
  erb :test_user_page, :locals  => {:profile_user => test_user }
end
get 'test_user/tweets' do
  test_user = UserService.get_by_username 'test_user'

  followees = test_user.followees
  user = followees | [test_user]
  ids = followees.collect { |user| user[:id] }

  tweets = TweetService.build_test_user_tweets ids, users

  erb :feed_tweets, :locals => {tweets: tweets }, :layout => false
end

get '/reset' do
  LoadTestService.reset
  redirect back
end
