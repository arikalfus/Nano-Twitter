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

      @browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
    end

    it 'loads the root page' do
      @browser.get '/'
      assert @browser.last_response.ok?

      @browser.last_request.env["rack.session"][:user] = @logged_in_user[:id]
      assert @browser.last_request.env["rack.session"][:user].must_equal @logged_in_user[:id]
    end

    describe get '/nanotwitter/v1.0/users/:username' do
      before do
        test_user = User.create({ name: 'Jerry Test',
                                      username: 'jertest4',
                                      password: 'jerrypass',
                                      phone: 1234567890,
                                    })

        @browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
      end

      it 'loads the user page' do
        @browser.get '/nanotwitter/v1.0/users/test_user[:username]'
        assert @browser.last_response.ok?

        

  end

end