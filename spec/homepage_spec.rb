ENV['RACK_ENV'] = 'test'

require_relative '../app'
require 'rspec'
require 'rack/test'


describe 'app' do
  include Rack::Test:Methods

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
    end

    it 'loads the root page' do
      get '/'
      expect(last_response).to be_ok

    end


  end

end