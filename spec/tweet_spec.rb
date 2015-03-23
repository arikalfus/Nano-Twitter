require_relative 'spec_helper'

describe "/tweet URI's" do

  def app
    Sinatra::Application
  end

  before :all do
    User.delete_all
    Tweet.delete_all
    Follow.delete_all

    @browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
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

    it 'should create a new tweet' do
      assert Tweet.find_by({:user_id => @user[:id], :text => 'Hello World!'}).must_equal nil
      @browser.post "/nanotwitter/v1.0/users/id/#{@user[:id]}/tweet", {:tweet => 'Hello World!'}
      @browser.follow_redirect!
      @browser.last_response.ok?
      tweet = Tweet.find_by({:user_id => @user[:id], :text => 'Hello World!'})
      refute_nil tweet
    end

  end

end