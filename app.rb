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
set :session_secret, '48fa3729hf0219f4rfbf39hf2'

get '/' do
  puts "User session: #{session[:user].to_json}"
  # Verify cookie contains current data.
  if session[:user]
    # If cookie is out of date, delete it.
    user = UserService.get_by_id session[:user]
    unless user
        session.clear
    end
  end

  if session[:user] # If user has credentials saved in session cookie (is logged in)
    user = UserService.get_by_id session[:user]
    users_to_follow = user.followees
    followees = users_to_follow.collect { |u| u[:id] }
    followees.push user[:id] # you should see your own tweets as well

    tweets = TweetService.tweets_by_user_id followees

    erb :logged_root, :locals => { :user => user, :tweets => tweets }
  elsif session[:login_error]
    tweets = TweetService.tweets

    login_error = session[:login_error]
    session[:login_error] = nil

    erb :root, :locals => { :tweets => tweets, :login_error => login_error }
  elsif session[:reg_error]
    tweets = TweetService.tweets

    reg_error = session[:reg_error]
    session[:reg_error] = nil

    erb :root, :locals => { :tweets => tweets, :reg_error => reg_error }
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
  form do
    filters :strip
    field :name, :present => true, :alpha_space => true
    field :email, :present => true, :email => true
    field :username, :present => true, :ascii => true, :length => 3..20
    field :password, :present => true, :ascii => true, :length => 8..30
    field :password2, :present => true, :ascii => true, :length => 8..30
    same :same_password, [:password, :password2]
    field :phone, :present => true, :int => true, :length => 10
  end

  if form.failed?
    # Note: All error messages must end with a space for proper formatting.
    session[:reg_error] = { :error_codes => [], :message => '' }

    # Form failed on :name
    if form.failed_on? :name, :present
      session[:reg_error][:error_codes].push 'r-n'
      session[:reg_error][:message] << 'You must enter a name. '
    elsif form.failed_on? :name, :alpha_space
      session[:reg_error][:error_codes].push 'r-nalpha'
      session[:reg_error][:message] << 'Your name must consist only of letters and spaces. '
    end

    # Form failed on :email
    if form.failed_on? :email, :present
      session[:reg_error][:error_codes].push 'r-e'
      session[:reg_error][:message] << 'You must enter an email. '
    elsif form.failed_on? :email, :email
      session[:reg_error][:error_codes].push 'r-einvalid'
      session[:reg_error][:message] << 'You must enter a correctly formatted email. '
    end

    # Form failed on :username
    if form.failed_on? :username, :present
      session[:reg_error][:error_codes].push 'r-u'
      session[:reg_error][:message] << 'You must enter a username. '
    elsif form.failed_on? :username, :ascii
      session[:reg_error][:error_codes].push 'r-uascii'
      session[:reg_error][:message] << 'Your username must only contain letters, digits, and ascii symbols. '
    elsif form.failed_on? :username, :length
      session[:reg_error][:error_codes].push 'r-ul'
      session[:reg_error][:message] << 'Your username must be between 3 and 20 characters. '
    end

    # Form failed on :password or :password2
    if form.failed_on? :password, :present
      session[:reg_error][:error_codes].push 'r-p'
      session[:reg_error][:message] << 'You must enter a password. '
    elsif form.failed_on? :password2, :present
      session[:reg_error][:error_codes].push 'r-p2'
      session[:reg_error][:message] << 'You must enter your password twice. '
    elsif form.failed_on? :password, :ascii
      session[:reg_error][:error_codes].push 'r-pascii'
      session[:reg_error][:message] << 'Your password must contain only letters, digits, and ascii symbols. '
    elsif form.failed_on? :password, :length
      session[:reg_error][:error_codes].push 'r-pl'
      session[:reg_error][:message] << 'Your password must be between 8 and 30 characters. '
    elsif form.failed_on? :same_password
      session[:reg_error][:error_codes].push 'r-pns'
      session[:reg_error][:message] << 'Your passwords do not match. '
    end

    # Form failed on :phone
    if form.failed_on? :phone, :present
      session[:reg_error][:error_codes].push 'r-ph'
      session[:reg_error][:message] << 'You must enter a phone. '
    elsif form.failed_on? :phone, :int
      session[:reg_error][:error_codes].push 'r-phint'
      session[:reg_error][:message] << 'Your phone number must only consist of digits. '
    elsif form.failed_on? :phone, :length
      session[:reg_error][:error_codes].push 'r-phl'
      session[:reg_error][:message] << 'Your phone number must contain 10 digits (US numbers only). '
    end

    redirect to '/'
  else
    user = UserService.new(name: form[:name],
                           email: form[:email],
                           username: form[:username],
                           password: form[:password],
                           phone: form[:phone])
    if user
      session[:user] = user[:id]
      puts "User session 1: #{session[:user].to_json}"
      redirect to '/'
    else
      error 400, user.errors.to_json
    end
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

# udpate an existing user using follow functions.
post '/nanotwitter/v1.0/users/:username/follow' do
  if session[:user]
    logged_in_user = UserService.get_by_id session[:user]
    followee = User.find_by_username params[:username]

    logged_in_user.follow followee
    redirect back
  else
    error 401, { :error => 'must be logged in to access' }.to_json # must be logged in to access
  end
end

post '/nanotwitter/v1.0/users/:username/unfollow' do
  if session[:user]
    logged_in_user = UserService.get_by_id session[:user]
    followee = User.find_by_username params[:username]
    logged_in_user.unfollow followee
    redirect back
  else
    error 401, { :error => 'must be logged in to access' }.to_json # must be logged in to access
  end
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
