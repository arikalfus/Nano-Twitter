require 'sinatra/activerecord'

require_relative 'models/tweet'
require_relative 'models/user'

class TweetService

def self.tweets_by_user_id(user_id)
  tweets = Tweet.where(user_id: user_id).limit(25).order created_at: :desc
  full_tweets = []
  tweets.each do |tweet|
    user = User.find_by_id tweet[:user_id]
    full_tweets.push [tweet, user]
  end

  full_tweets
end

  def self.tweets
    tweets = Tweet.limit(25).order created_at: :desc
    full_tweets = []
    tweets.each do |tweet|
      user = User.find_by_id tweet[:user_id]
      full_tweets.push [tweet, user]
    end

    full_tweets
  end

  def self.new(params)
    begin
      tweet = Tweet.create(
          text: params[:text],
          user_id: params[:user_id]
      )

      if tweet.valid?
        tweet.to_json
      else
        error 400, tweet.errors.to_json
      end
    end
  end

end