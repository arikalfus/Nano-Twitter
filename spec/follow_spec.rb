require_relative 'spec_helper'

describe 'following and unfollowing a user' do

  def app
    Sinatra::Application
  end

  before :all do
    User.delete_all
    Tweet.delete_all
    Follow.delete_all

    @browser = Rack::Test::Session.new(Rack::MockSession.new(app))
  end

  describe 'POST on /nanotwitter/v1.0/users/:username/follow' do

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

    it 'should verify cookie is present' do
      @browser.get '/'
      assert @browser.last_response.ok?, 'Last response was not ok'
      assert @browser.last_request.env['rack.session'][:user].must_equal @logged_in_user[:id], 'Session user ID does not equal user ID'
    end

    it 'follow the user' do

      @followee = User.create({  name: 'followee',
                                 username: 'followeeUserName',
                                 password: 'followeePass',
                                 phone: 1122313,
                              })

      assert @logged_in_user.following?(@followee).must_equal false, 'Following was not false'

      @browser.post '/nanotwitter/v1.0/users/followeeUserName/follow'
      @browser.follow_redirect!
      assert @browser.last_response.ok?, 'Last response was not ok'
      assert @logged_in_user.following?(@followee), 'Following was not true'
    end

  end

  describe 'POST on /nanotwitter/v1.0/users/:username/unfollow' do

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

    it 'should verify cookie is present' do
      @browser.get '/'
      assert @browser.last_response.ok?
      assert @browser.last_request.env['rack.session'][:user].must_equal @logged_in_user[:id], 'Session user ID does not equal user ID'
    end

    it 'should unfollow a user' do

      @followee = User.create({  name: 'followee',
                                 username: 'followeeUserName',
                                 password: 'followeePass',
                                 phone: 1122313,
                              })

      @logged_in_user.follow @followee
      assert @logged_in_user.following?(@followee), 'Following was not true'
      @browser.post '/nanotwitter/v1.0/users/followeeUserName/unfollow'
      @browser.follow_redirect!
      assert @browser.last_response.ok?, 'Last response was not ok'

      assert @logged_in_user.following?(@followee).must_equal false, 'Following was not false'
    end

  end

end