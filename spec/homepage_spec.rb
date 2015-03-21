ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'


require_relative '../app'

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

  describe 'GET on /' do

    before do
      @logged_in_user = User.create({ name: 'Jerry Test',
        username: 'jertest4',
        password: 'jerrypass',
        phone: 1234567890,
        })

      Tweet.create([{user_id: @logged_in_user[:id], text: 'Try to parse the GB interface, maybe it will navigate the bluetooth sensor!' },
        {user_id: @logged_in_user[:id], text: 'Hello world!'}
        ])
    end

    it 'loads the root page' do
      @browser.get '/'
      assert @browser.last_response.ok?

      #assert @browser.last_response.body.wont_include 'You have been logged out.', '"you have been logged out." was included in the root page'

      @browser.last_request.env["rack.session"][:user] = @logged_in_user[:id]
      assert @browser.last_request.env["rack.session"][:user].must_equal @logged_in_user[:id]
    end

  end

  describe 'GET on /logout and GET and /nanotwitter/v1.0/logout' do

    before do
      @logged_in_user = User.create({ name: 'Jerry Test',
        username: 'jertest4',
        password: 'jerrypass',
        phone: 1234567890,
        })

      Tweet.create([{user_id: @logged_in_user[:id], text: 'Try to parse the GB interface, maybe it will navigate the bluetooth sensor!' },
                    {user_id: @logged_in_user[:id], text: 'Hello world!'}
                   ])
    end

    it 'loads the logout page and delete the user from session' do
      @browser.get '/logout'
      assert @browser.last_response.ok?

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
end


