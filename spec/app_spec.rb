require_relative 'spec_helper'

class AppSpec < Minitest::Test

  describe 'app' do

    include Rack::Test::Methods

    def app
      Sinatra::Application
    end

    before :all do
      User.destroy_all
      Tweet.destroy_all
      Follow.destroy_all

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

        if @browser.last_request.env["rack.session"][:user] == @test_session_user[:id]
          html_text = @browser.last_response.body.pretty_inspect
          html_text.must_include(<input class="form-control input-sm " type="text" name="tweet" id="message" placeholder="Message" maxlength="140" rows="7">)
        end
      end

      it 'loads another user page'
      @browser.get "/nanotwitter/v1.0/users/terjest4"
         assert @browser.last_response.ok?

         if @browser.last_request.env["rack.session"][:user] != @test_session_user[:id]
          html_text = @browser.last_response.body.pretty_inspect
          html_text.must_include(<form action="/nanotwitter/v1.0/users/<%= profile_user[:username] %>/follow" method="post">)
        end
    end
   end
  end
end