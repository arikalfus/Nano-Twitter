require_relative 'spec_helper'

describe 'root page' do

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before :all do
    User.delete_all
    Tweet.delete_all
    Follow.delete_all

    @browser = Rack::Test::Session.new(Rack::MockSession.new(app))
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
      assert @browser.last_request.env['rack.session'][:user].must_equal @logged_in_user[:id], 'Session user ID is not equal to user ID'
    end

    it 'should load logged_root if user is logged in' do
      @browser.get '/'
      assert @browser.last_response.ok?, 'Last response was not ok'
      assert @browser.last_request.env['rack.session'][:user].must_equal @logged_in_user[:id], 'Session user ID is not equal to user ID'

      refute @browser.last_response.body.empty?, 'Body is empty'
      assert @browser.last_response.body.must_include 'Logout' # in logged_root, but not root
    end

    it 'should delete a cookie if user data is out of date' do
      User.destroy(@logged_in_user[:id])
      user = UserService.get_by_id(@browser.last_request.env['rack.session'][:user])
      assert user.must_be_nil, 'User is not nil'
      @browser.get '/'
      assert @browser.last_response.ok?, 'Last response was not ok'
      assert @browser.last_request.env['rack.session'][:user].must_be_nil, 'session cookie is not nil'
    end

    it 'should load with a login error if user incorrectly logs in' do
      @browser.post '/nanotwitter/v1.0/users/session', { :username => 'jertest4', :password => 'incorrectpassword' }
      @browser.follow_redirect!
      assert @browser.last_response.ok?, 'Response status was not 200'

      assert @browser.last_request.env['rack.session.options'][:path].must_equal '/', 'Request path does not include "/"'
      assert @browser.last_request.env['rack.session'][:login_error][:error_codes].must_include 'l-inv', 'Login error not found in session cookie'
      assert @browser.last_response.body.must_include 'Logout', "'Logout' not found in response body"
    end

  end

end