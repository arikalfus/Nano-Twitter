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

    it "should verify a user's credentials" do

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

    it 'should verify cookie is present' do
      @browser.get '/'
      assert @browser.last_response.ok?, 'Last response was not ok'
      assert @browser.last_request.env["rack.session"][:user].must_equal @logged_in_user[:id], 'Session user id is not equal to user'
    end

    it 'should load logged_root if user is logged in' do
      @browser.get '/'
      assert @browser.last_response.ok?, 'Last response was not ok'
      assert @browser.last_request.env["rack.session"][:user].must_equal @logged_in_user[:id], 'Session user id is not equal to user'

      assert !@browser.last_response.body.empty?, 'Body is empty'
      assert @browser.last_response.body.must_include 'Logout' # in logged_root, but not root
    end

    it 'should delete a cookie if user data is out of date' do
      User.destroy(@logged_in_user[:id])
      user = User.find_by_id(@browser.last_request.env['rack.session'][:user])
      assert user.must_be_nil, 'User is not nil'
      @browser.get '/'
      assert @browser.last_response.ok?, 'Last response was not ok'
      assert @browser.last_request.env['rack.session'][:user].must_be_nil, 'session cookie is not nil'
    end

    it 'should load with a login error if user incorrectly logs in' do
      @browser.post '/nanotwitter/v1.0/users/session', { :username => 'jertest4', :password => 'incorrectpassword' }
      @browser.follow_redirect!
      assert @browser.last_response.ok?, 'Response status was not 200'

      assert @browser.last_request.env["rack.session.options"][:path].must_equal '/'
      assert @browser.last_request.env['rack.session'][:login_error][:error_codes].must_include 'l-inv'
      assert @browser.last_response.body.must_include 'Logout'
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

    it 'should unfollow a user' do

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

  describe  'get /nanotwitter/v1.0/users/:username' do
    before do
      @test_session_user = User.create({ name: 'Jerry Test',
                                      username: 'jertest4',
                                      password: 'jerrypass',
                                      phone: 1234567890,
                                    })
      @test_user = User.create({ name: 'Terry Jest',
                                      username: 'terjest4',
                                      password: 'terrypass',
                                      phone: 1234567891,
                                    })

      @browser.post '/nanotwitter/v1.0/users/session', { :username => 'jertest4', :password => 'jerrypass' }
      @browser.follow_redirect!
    end

    it 'loads the user page of logged in user' do
      @browser.get "/nanotwitter/v1.0/users/jertest4"
      assert @browser.last_response.ok?
      assert @browser.last_request.env["rack.session"][:user].must_equal @test_session_user[:id], "ID's are not equal"

      html_text = @browser.last_response.body.pretty_inspect
      assert html_text.must_include('maxlength=\"140\"')
    end

    it 'loads another user page' do
      @browser.get "/nanotwitter/v1.0/users/terjest4"
      assert @browser.last_response.ok?, "This is where it's failing"

      html_text = @browser.last_response.body.pretty_inspect
      assert html_text.must_include('Follow')
    end
  end
  
end
