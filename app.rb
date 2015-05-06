require 'sinatra'
require 'tilt/erb'
require 'sinatra/activerecord'
require 'sinatra/formkeeper'
require 'redis'
require 'json'

require_relative 'services/form_service'
require_relative 'services/load_test_service'
require_relative 'services/tweet_service'
require_relative 'services/redis_service'
require_relative 'services/user_service'
require_relative 'models/follow'

# Configure server environment
configure do

  env = ENV['SINATRA_ENV'] || 'development'
  databases = YAML.load(ERB.new(File.read('config/database.yml')).result)
  ActiveRecord::Base.establish_connection databases[env]

  set :port, 3765
  set :public_folder, File.dirname(__FILE__) + '/static'
  enable :sessions
  set :session_secret, '48fa3729hf0219f4rfbf39hf2'

  # Connect to Redis server with Hiredis driver for speed
  $redis = Redis.new(
                    :driver => :hiredis,
                    :host => 'pub-redis-13514.us-east-1-3.2.ec2.garantiadata.com',
                    :port => '13514',
                    :password => 'nanotwitter'
  )

end

# Set helper methods
helpers do

  # Cache first 100 tweets in redis
  #
  # see #render_tweets and RedisService#cache_tweets
  def start_caching
    tweets_array = TweetService.tweets
    html_array = render_tweets tweets_array
    RedisService.cache_tweets html_array, $redis
  end

  # Render tweets into html strings
  def render_tweets(tweets_array)
    html_tweets = Array.new
    tweets_array.each do |tweet, user|
      html = erb :tweet, :locals => { tweet: tweet, user: user }, :layout => false
      html_tweets.push html
    end

    html_tweets
  end

  # Caches array of html-rendered tweets into redis
  #
  # see RedisService#cache
  def cache_tweets(html_array, key)
    html_array.each do |html|
      RedisService.cache html, key, $redis
    end
  end

  # Renders a single tweet into html and caches it in redis
  def render_tweet(tweet)
    user = UserService.get_by_id tweet.user_id
    html = erb :tweet, :locals => { tweet: tweet, user: user }, :layout => false
    RedisService.cache html, 'firehose', $redis
  end

  # Get 100 most recent tweets
  def get_tweets(key)
    RedisService.get_100_tweets key, $redis
  end

  # Get html-rendered tweets of user_id (may be an array of ID's)
  def get_tweets_by_id(user_id, user=nil)
    tweets = Array.new
    if user
      tweets = TweetService.tweets_by_user_id user_id, user
    else
      tweets = TweetService.tweets_by_user_id user_id
    end

    render_tweets tweets
  end

end

$redis.del 'firehose' # cache resets when server starts/is woken up

# ------
# ROUTES BELOW
#-------

# for load testing with Loader.io
get '/loaderio-7b84b69492913d259b5266ab9f52dea7/' do
  send_file File.new 'loaderio-7b84b69492913d259b5266ab9f52dea7.txt'
end

# for Pito's load testing
get '/loaderio-7075d4380f6f2dacc9025ebdc486490d/' do
	send_file File.new 'loaderio-7075d4380f6f2dacc9025ebdc486490d.txt'
end

get '/' do
  tweets_cached = RedisService.validate_cache 'firehose', $redis

  if tweets_cached

    # Verify cookie contains current data.
    if session[:user]
      # If cookie is out of date, delete it.
      user = UserService.get_by_id session[:user]
      unless user
        session.clear # delete session cookie
      end
    end

    tweets = get_tweets 'firehose' # get 100 most recent tweets

    if session[:user] # If user has credentials saved in session cookie
      erb :logged_root, :locals => { user: user, tweets: tweets }

    elsif session[:login_error] # if user entered invalid login credentials
      login_error = session[:login_error]
      session[:login_error] = nil
      erb :root, :locals => { login_error: login_error, tweets: tweets }

    elsif session[:reg_error] # if user encountered an error during account registration
      reg_error = session[:reg_error]
      session[:reg_error] = nil
      erb :root, :locals => { reg_error: reg_error, tweets: tweets }

    else # load default root page
      erb :root, :locals => { tweets: tweets }
    end

  else
    start_caching
    redirect to '/'
  end

end

get '/logout' do
  redirect to '/nanotwitter/v1.0/logout' unless session[:user].nil?

  tweets = get_tweets 'firehose' # get 100 most recent tweets
  erb :root, :locals => { logout: true, tweets: tweets }
end

# logout and delete session cookie
get '/nanotwitter/v1.0/logout' do
  session.clear
  redirect to '/logout'
end

get '/nanotwitter/v1.0/users/:username' do
<<<<<<< HEAD
=======

  # for load testing
>>>>>>> master
  redirect to '/test_user' if params[:username] == 'test_user'

  user = UserService.get_by_username params[:username]
  tweets = get_tweets_by_id user.id

<<<<<<< HEAD
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
=======
  if session[:user] # load user page with follow/unfollow button
    logged_in_user = UserService.get_by_id session[:user]
    if user && logged_in_user
      erb :user_page, :locals => { user: logged_in_user, profile_user: user, tweets: tweets }
    else
      error 404, { :error => 'user not found' }.to_json
    end
  elsif user # load user page without follow/unfollow button
    erb :user_page,  :locals => { profile_user: user, tweets: tweets }
  else
    error 404, { :error => 'user not found' }.to_json
  end
>>>>>>> master

end

# Get a user by id
get '/nanotwitter/v1.0/users/id/:id' do
  user = UserService.get_by_id params[:id]
  redirect to "/nanotwitter/v1.0/users/#{user.username}" # not efficient, but effective
end

# CAN ONLY BE CALLED BY A USER WHO IS LOGGED IN
get '/nanotwitter/v1.0/users/:username/profile' do
  if session[:user] # If user has credentials saved in session cookie
    logged_in_user = UserService.get_by_id session[:user]
    user = UserService.get_by_username params[:username]
    if logged_in_user.username == user.username # if user is requesting their own page
      erb :user_profile, :locals => { :user => logged_in_user }
    else
      error 403, { :error=> 'forbidden from accessing this page' }.to_json
    end
  else
    error 401, { :error => 'must be logged in to access' }.to_json
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

  # construct string message if there exist any failures
  failures = FormService.validate_registration form

  if failures
    session[:reg_error] = failures[:reg_error] # store message in session
    redirect to '/'
  else
    user = UserService.new(name: form[:name],
                           email: form[:email],
                           username: form[:username],
                           password: form[:password],
                           phone: form[:phone])
    if user
      session[:user] = user.id
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

    search_terms = form[:search] # grab parameter with form filters applied
    users = UserService.search_for search_terms
    erb :search_results, :locals => { results: users, search_term: search_terms }
  end

end

# Post a new tweet and store the rendered html into Redis
post '/nanotwitter/v1.0/users/id/:id/tweet' do
    tweet = TweetService.new(text: params[:tweet],
                             user_id: params[:id])
    render_tweet tweet
    redirect back
end

# verify a user name and password
post '/nanotwitter/v1.0/users/session' do
  user = UserService.get_by_username_and_password({ username: params[:username], password: params[:password] })
  if user
    session[:user] = user.id
  else
    session[:login_error] = { error_codes: ['l-inv'], message: 'Account credentials are invalid.' }
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
    error 401, { :error => 'must be logged in to access' }.to_json
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
    error 401, { :error => 'must be logged in to access' }.to_json
  end
end

get '/test_tweet' do 
  tweet = LoadTestService.test_tweet
  render_tweet tweet # render into html and cache tweet in redis
end

get '/test_follow' do
  LoadTestService.test_follow # follow a random user
end

get '/test_user' do
  test_user = UserService.get_by_username 'test_user'

  followees = test_user.followees
  users = followees | [test_user] # load followees' as well as your own tweets
  ids = users.collect { |user| user.id }

  tweets = get_tweets_by_id ids, users

  erb :test_user_page, :locals  => { profile_user: test_user, tweets: tweets }
end

# Destroy all test_user data from the database and reset the Redis cache
get '/reset' do
  LoadTestService.reset
  $redis.del 'firehose'
  redirect to '/' # will re-cache most recent tweets
end

get '/test_user' do
  test_user = UserService.get_by_username "test_user"
  
  followees_ids = test_user.followees.select(:id)
  followees_ids.push test_user
  followees_ids.collect! { |user| user[:id] }
  tweets = Tweet.where(id: followees_ids)
  erb :user_page,  :locals => { :profile_user => test_user, :tweets => tweets }

end


