require_relative 'spec_helper'

describe 'tweet_service' do

  include Rack::Test::Methods

  before :all do
    User.delete_all
    Tweet.delete_all
    Follow.delete_all
    #User.base_uri = "http://localhost:3000"
    @user = User.create({name: 'Jerry test',
                         username: 'jertest4',
                         password: 'jerrypass',
                         phone: 1234567890
                        })
  end

  it "should create a tweet with user_id and text" do
    tweet = TweetService.new({text: 'Try to parse the GB interface, maybe it will navigate the bluetooth sensor!',
                                 user_id: @user[:id]})

    assert tweet["text"].must_equal 'Try to parse the GB interface, maybe it will navigate the bluetooth sensor!'
    assert tweet["user_id"].must_equal @user[:id]
  end

  it "should get an array of tweets by user_id" do
    tweet = TweetService.new({text: 'Try to parse the GB interface, maybe it will navigate the bluetooth sensor!',
                         user_id: @user[:id]})

    full_tweets = TweetService.tweets_by_user_id(@user[:id])

    puts full_tweets.first.pretty_inspect

    assert full_tweets.first["text"].must_equal 'Try to parse the GB interface, maybe it will navigate the bluetooth sensor!'
    assert full_tweets.first["user_id"].must_equal @user[:id]
  end


end