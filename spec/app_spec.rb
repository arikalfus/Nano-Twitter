require_relative 'spec_helper'

describe 'app' do

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before :each do
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





end

