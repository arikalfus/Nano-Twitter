require_relative 'spec_helper'

describe 'app' do

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before :all do
    User.delete_all
    Tweet.delete_all
    Follow.delete_all

    @browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
  end

  describe 'POST on /nanotwitter/v1.0/users/session' do

    before do
      @user = User.create({name: 'Jerry test',
                           username: 'jertest4',
                           password: 'jerrypass',
                           phone: 1234567890
                          })
    end

    it "verifies a user's credentials" do

      @browser.post '/nanotwitter/v1.0/users/session', { :username => 'jertest4', :password => 'jerrypass' }
      assert @browser.last_response.location.must_equal 'http://example.org/', 'Redirect location is not root'

      @browser.follow_redirect!
      assert @browser.last_response.ok?

      assert @browser.last_request.env['rack.session'][:user].must_equal @user[:id], 'Session user id is not equal to user'
    end
  end

  describe 'GET on /' do

    before do
    # create a user and 2 tweets
      @logged_in_user = User.create({ name: 'Jerry Test',
                                      username: 'jertest4',
                                      password: 'jerrypass',
                                      phone: 1234567890
                                   })
      Tweet.create([{user_id: @logged_in_user[:id], text: 'Try to parse the GB interface, maybe it will navigate the bluetooth sensor!' },
                   {user_id: @logged_in_user[:id], text: 'Hello world!'}
                   ])
      # save user session cookie
      @browser.post '/nanotwitter/v1.0/users/session', { :username => 'jertest4', :password => 'jerrypass' }
      @browser.follow_redirect!
    end
    it 'verify cookie is present' do
      @browser.get '/'
      assert @browser.last_response.ok?
      assert @browser.last_request.env["rack.session"][:user].must_equal @logged_in_user[:id]
    end
  end




  describe "POST on /nanotwitter/v1.0/users/:username/follow" do 

    before do
    # create a user and 2 tweets
      @logged_in_user = User.create({ name: 'Jerry Test',
                                      username: 'jertest4',
                                      password: 'jerrypass',
                                      phone: 1234567890
                                   })
      # save user session cookie
      @browser.post '/nanotwitter/v1.0/users/session', { :username => 'jertest4', :password => 'jerrypass' }
      @browser.follow_redirect!
    end

    it 'verify cookie is present' do
      @browser.get '/'
      assert @browser.last_response.ok?
      assert @browser.last_request.env["rack.session"][:user].must_equal @logged_in_user[:id]
    end

    it 'follow the user' do

      @followee = User.create({  name: 'followee',
                                username: 'followeeUserName',
                                password: 'followeePass',
                                phone: 1122313,
                            })
      
      assert @logged_in_user.following?(@followee).must_equal false

      @browser.post '/nanotwitter/v1.0/users/followeeUserName/follow'
      @browser.follow_redirect!
      assert @browser.last_response.ok?
      assert @logged_in_user.following?(@followee)
    end
  
  end



  describe "POST on /nanotwitter/v1.0/users/:username/unfollow" do 

    before do
    # create a user and 2 tweets
      @logged_in_user = User.create({ name: 'Jerry Test',
                                      username: 'jertest4',
                                      password: 'jerrypass',
                                      phone: 1234567890
                                   })
      # save user session cookie
      @browser.post '/nanotwitter/v1.0/users/session', { :username => 'jertest4', :password => 'jerrypass' }
      @browser.follow_redirect!
    end

    it 'verify cookie is present' do
      @browser.get '/'
      assert @browser.last_response.ok?
      assert @browser.last_request.env["rack.session"][:user].must_equal @logged_in_user[:id]
    end

    it 'unfollow the user' do

      @followee = User.create({  name: 'followee',
                                username: 'followeeUserName',
                                password: 'followeePass',
                                phone: 1122313,
                            })
      
      @logged_in_user.follow @followee
      assert @logged_in_user.following?(@followee)
      @browser.post '/nanotwitter/v1.0/users/followeeUserName/unfollow'
      @browser.follow_redirect!
      assert @browser.last_response.ok?

      assert @logged_in_user.following?(@followee).must_equal false
    end
  end






  describe 'GET on /logout and GET on /nanotwitter/v1.0/logout' do

    before do
      @logged_in_user = User.create({ name: 'Jerry Test',
                                      username: 'jertest4',
                                      password: 'jerrypass',
                                      phone: 1234567890,
                                    })
      Tweet.create([{user_id: @logged_in_user[:id], text: 'Try to parse the GB interface, maybe it will navigate the bluetooth sensor!' },
                    {user_id: @logged_in_user[:id], text: 'Hello world!'}
                   ])
      # save user session cookie
      @browser.post '/nanotwitter/v1.0/users/session', { :username => 'jertest4', :password => 'jerrypass' }
      @browser.follow_redirect!
    end
    it 'loads the logout page and delete the user from session' do
      @browser.get '/logout'
      @browser.follow_redirect!
      @browser.follow_redirect!
      assert @browser.last_response.ok?, 'response is not 200'
      #Asserts that the user was deleted from the current session cookie
      assert @browser.last_request.env["rack.session"][:user].must_be_nil, 'did not delete the user from session'
      #Asserts that the rendered page has the logged out message and that it loads the recent tweets from the database
      assert @browser.last_response.body.must_include 'You have been logged out.', 'did not include: "you have been logged out."'
      assert @browser.last_response.body.must_include 'Hello world', 'did not include: "hello world"'
    end
    it 'loads the API logout page and delete the user from session' do
      @browser.get '/nanotwitter/v1.0/logout'
      #Asserts that the user was deleted from the current session cookie
      assert @browser.last_request.env["rack.session"][:user].must_be_nil, 'did not delete the user from session'
      #asserts that browser redirect to /logout
      @browser.follow_redirect!
      assert @browser.last_response.ok?
      #Asserts that the browser redirected back to /logout
      assert @browser.last_request.env["PATH_INFO"].must_equal "/logout", 'did not request /logout'
      #Asserts that the rendered page has the logged out message and that it loads the recent tweets from the database
      assert @browser.last_response.body.must_include 'You have been logged out.', 'did not include: "you have been logged out."'
      assert @browser.last_response.body.must_include 'Hello world', 'did not include: "hello world"'
    end
  end


    describe "POST on /nanotwitter/v1.0/users/id/:id/tweet" do 

    before do
    # create a user and 2 tweets
      @user = User.create({           
                            name: 'Jerry Test',
                            username: 'jertest4',
                            password: 'jerrypass',
                            phone: 1234567890
                          })
    end

    it 'create a new tweet' do
      
      assert Tweet.find_by({:user_id => @user[:id], :text => 'Hello World!'}).must_equal nil
      @browser.post "/nanotwitter/v1.0/users/id/#{@user[:id]}/tweet", {:tweet => 'Hello World!'}
      @browser.follow_redirect!
      @browser.last_response.ok?

      assert Tweet.find_by({:user_id => @user[:id], :text => 'Hello World!'})

    end
  
  end
  


  describe "POST on /nanotwitter/v1.0/users" do

    User.delete_all
    it 'create a new user with valid credentials' do
      @browser.post "/nanotwitter/v1.0/users", {
                                                      :name => 'Aviv Dev', 
                                                      :email => 'Aviv@Devdev.com',
                                                      :username => 'AvivDev', 
                                                      :password => '33d321421',
                                                      :password2 => '33d321421',
                                                      :phone => 4453239920
                                               }
      assert @browser.last_request.env['rack.session'][:reg_error].must_be_nil, 'some credentials are invalid'      
      assert @browser.last_response.location.must_equal 'http://example.org/', 'Redirect location is not root'
      @browser.follow_redirect!
      assert @browser.last_response.ok?
    end

    User.delete_all
    it 'create a new user with empty name' do
      @browser.post "/nanotwitter/v1.0/users", {
                                                      :name => '', 
                                                      :email => 'AvivDev@dev.com',
                                                      :username => 'AvivDev', 
                                                      :password => '33d321421',
                                                      :password2 => '33d321421',
                                                      :phone => 4453239920
                                               }
      assert @browser.last_request.env['rack.session'][:reg_error][:error_codes].must_include 'r-n', 'user name is empty'
      assert @browser.last_response.location.must_equal 'http://example.org/', 'Redirect location is not root'
      @browser.follow_redirect!
      assert @browser.last_response.ok?
    end

    User.delete_all
    it 'create a new user with invalid name' do
      @browser.post "/nanotwitter/v1.0/users", {
                                                      :name => 'Aviv ♣ Dev', 
                                                      :email => 'AvivDev@dev.com',
                                                      :username => 'AvivDev', 
                                                      :password => '33d321421',
                                                      :password2 => '33d321421',
                                                      :phone => 4453239920
                                               }
      assert @browser.last_request.env['rack.session'][:reg_error][:error_codes].must_include 'r-nalpha', 'user name is empty'
      assert @browser.last_response.location.must_equal 'http://example.org/', 'Redirect location is not root'
      @browser.follow_redirect!
      assert @browser.last_response.ok?
    end

    User.delete_all
    it 'create a new user with empty email' do
      @browser.post "/nanotwitter/v1.0/users", {
                                                      :name => 'Aviv Dev', 
                                                      :email => '',
                                                      :username => 'AvivDev', 
                                                      :password => '33d321421',
                                                      :password2 => '33d321421',
                                                      :phone => 4453239920
                                               }
      assert @browser.last_request.env['rack.session'][:reg_error][:error_codes].must_include 'r-e', 'user name is empty'
      assert @browser.last_response.location.must_equal 'http://example.org/', 'Redirect location is not root'
      @browser.follow_redirect!
      assert @browser.last_response.ok?
    end

    User.delete_all
    it 'create a new user with invalid email' do
      @browser.post "/nanotwitter/v1.0/users", {
                                                      :name => 'Aviv Dev', 
                                                      :email => 'AvivDevdev.com',
                                                      :username => 'AvivDev', 
                                                      :password => '33d321421',
                                                      :password2 => '33d321421',
                                                      :phone => 4453239920
                                               }
      assert @browser.last_request.env['rack.session'][:reg_error][:error_codes].must_include 'r-einvalid', 'user name is empty'
      assert @browser.last_response.location.must_equal 'http://example.org/', 'Redirect location is not root'
      @browser.follow_redirect!
      assert @browser.last_response.ok?
    end

    User.delete_all
    it 'create a new user with empty username' do
      @browser.post "/nanotwitter/v1.0/users", {
                                                      :name => 'Aviv Dev', 
                                                      :email => 'AvivDev@dev.com',
                                                      :username => '', 
                                                      :password => '33d321421',
                                                      :password2 => '33d321421',
                                                      :phone => 4453239920
                                               }
      assert @browser.last_request.env['rack.session'][:reg_error][:error_codes].must_include 'r-u', 'user name is empty'
      assert @browser.last_response.location.must_equal 'http://example.org/', 'Redirect location is not root'
      @browser.follow_redirect!
      assert @browser.last_response.ok?
    end

    User.delete_all
    it 'create a new user with invalid username' do
      @browser.post "/nanotwitter/v1.0/users", {
                                                      :name => 'Aviv Dev', 
                                                      :email => 'AvivDev@dev.com',
                                                      :username => 'Aviv♠Dev', 
                                                      :password => '33d321421',
                                                      :password2 => '33d321421',
                                                      :phone => 4453239920
                                               }
      assert @browser.last_request.env['rack.session'][:reg_error][:error_codes].must_include 'r-uascii', 'user name is empty'
      assert @browser.last_response.location.must_equal 'http://example.org/', 'Redirect location is not root'
      @browser.follow_redirect!
      assert @browser.last_response.ok?
    end

    User.delete_all
    it 'create a new user with empty password' do
      @browser.post "/nanotwitter/v1.0/users", {
                                                      :name => 'Aviv Dev', 
                                                      :email => 'AvivDev@dev.com',
                                                      :username => 'AvivDev', 
                                                      :password => '',
                                                      :password2 => '33d321421',
                                                      :phone => 4453239920
                                               }
      assert @browser.last_request.env['rack.session'][:reg_error][:error_codes].must_include 'r-p', 'user name is empty'
      assert @browser.last_response.location.must_equal 'http://example.org/', 'Redirect location is not root'
      @browser.follow_redirect!
      assert @browser.last_response.ok?
    end

    User.delete_all
    it 'create a new user with invalid password' do
      @browser.post "/nanotwitter/v1.0/users", {
                                                      :name => 'Aviv Dev', 
                                                      :email => 'AvivDev@dev.com',
                                                      :username => 'AvivDev', 
                                                      :password => '33d32♠1421',
                                                      :password2 => '33d321421',
                                                      :phone => 4453239920
                                               }
      assert @browser.last_request.env['rack.session'][:reg_error][:error_codes].must_include 'r-pascii', 'user name is empty'
      assert @browser.last_response.location.must_equal 'http://example.org/', 'Redirect location is not root'
      @browser.follow_redirect!
      assert @browser.last_response.ok?
    end

    User.delete_all
    it 'create a new user with empty password2' do
      @browser.post "/nanotwitter/v1.0/users", {
                                                      :name => 'Aviv Dev', 
                                                      :email => 'AvivDev@dev.com',
                                                      :username => 'AvivDev', 
                                                      :password => '33d321421',
                                                      :password2 => '',
                                                      :phone => 4453239920
                                               }
      assert @browser.last_request.env['rack.session'][:reg_error][:error_codes].must_include 'r-p2', 'user name is empty'
      assert @browser.last_response.location.must_equal 'http://example.org/', 'Redirect location is not root'
      @browser.follow_redirect!
      assert @browser.last_response.ok?
    end

    User.delete_all
    it 'create a new user with invalid password length' do
      @browser.post "/nanotwitter/v1.0/users", {
                                                      :name => 'Aviv Dev', 
                                                      :email => 'AvivDev@dev.com',
                                                      :username => 'AvivDev', 
                                                      :password => '321',
                                                      :password2 => '33d321421',
                                                      :phone => 4453239920
                                               }
      assert @browser.last_request.env['rack.session'][:reg_error][:error_codes].must_include 'r-pl', 'user name is empty'
      assert @browser.last_response.location.must_equal 'http://example.org/', 'Redirect location is not root'
      @browser.follow_redirect!
      assert @browser.last_response.ok?
    end

    User.delete_all
    it 'create a new user with non-matching passwords' do
      @browser.post "/nanotwitter/v1.0/users", {
                                                      :name => 'Aviv Dev', 
                                                      :email => 'AvivDev@dev.com',
                                                      :username => 'AvivDev', 
                                                      :password => '3333211111143421',
                                                      :password2 => '33d321421',
                                                      :phone => 4453239920
                                               }
      assert @browser.last_request.env['rack.session'][:reg_error][:error_codes].must_include 'r-pns', 'user name is empty'
      assert @browser.last_response.location.must_equal 'http://example.org/', 'Redirect location is not root'
      @browser.follow_redirect!
      assert @browser.last_response.ok?
    end

    User.delete_all
    it 'create a new user with empty phone' do
      @browser.post "/nanotwitter/v1.0/users", {
                                                      :name => 'Aviv Dev', 
                                                      :email => 'AvivDev@dev.com',
                                                      :username => 'AvivDev', 
                                                      :password => '33d321421',
                                                      :password2 => '33d321421',
                                                      :phone => ''
                                               }
      assert @browser.last_request.env['rack.session'][:reg_error][:error_codes].must_include 'r-ph', 'user name is empty'
      assert @browser.last_response.location.must_equal 'http://example.org/', 'Redirect location is not root'
      @browser.follow_redirect!
      assert @browser.last_response.ok?
    end

    User.delete_all
    it 'create a new user with invalid phone characters' do
      @browser.post "/nanotwitter/v1.0/users", {
                                                      :name => 'Aviv Dev', 
                                                      :email => 'AvivDev@dev.com',
                                                      :username => 'AvivDev', 
                                                      :password => '33d321421',
                                                      :password2 => '33d321421',
                                                      :phone => '44533534a3'
                                               }
      assert @browser.last_request.env['rack.session'][:reg_error][:error_codes].must_include 'r-phint', 'user name is empty'
      assert @browser.last_response.location.must_equal 'http://example.org/', 'Redirect location is not root'
      @browser.follow_redirect!
      assert @browser.last_response.ok?
    end

    User.delete_all
    it 'create a new user with invalid phone length' do
      @browser.post "/nanotwitter/v1.0/users", {
                                                      :name => 'Aviv Dev', 
                                                      :email => 'AvivDev@dev.com',
                                                      :username => 'AvivDev', 
                                                      :password => '33d321421',
                                                      :password2 => '33d321421',
                                                      :phone => '445335343'
                                               }
      assert @browser.last_request.env['rack.session'][:reg_error][:error_codes].must_include 'r-phl', 'user name is empty'
      assert @browser.last_response.location.must_equal 'http://example.org/', 'Redirect location is not root'
      @browser.follow_redirect!
      assert @browser.last_response.ok?
    end

  end












end
