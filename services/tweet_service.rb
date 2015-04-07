require 'sinatra/activerecord'

require_relative '../models/tweet'
require_relative 'user_service'

class TweetService

def self.tweets_by_user_id(user_id)
  tweets = Tweet.where(user_id: user_id).limit(100).order created_at: :desc
  full_tweets = []
  user_ids = []

  tweets.each do |tweet|
    user_ids.push tweet[:user_id]
  end
  users = UserService.get_by_ids user_ids

  tweets.each do |tweet|
    tweet_user = users.collect {|user| user[:id] == tweet[:user_id] }.first
    verify_tweet tweet_user, tweet, full_tweets
  end

  full_tweets
  end

  def self.tweets
    tweets = Tweet.limit(100).order created_at: :desc
    full_tweets = []
    user_ids = []

    tweets.each do |tweet|
      user_ids.push tweet[:user_id]
    end
    users = UserService.get_by_ids user_ids

    tweets.each do |tweet|
      tweet_user = nil
      users.each do |user|
        if user[:id] == tweet[:user_id]
          tweet_user = user
        end
      end
      puts tweet_user.pretty_inspect
      verify_tweet tweet_user, tweet, full_tweets
    end

    full_tweets
  end

  def self.new(params)
    begin
      tweet = Tweet.create(
          text: params[:text],
          user_id: params[:user_id]
      )

      if tweet
        tweet
      else
        error 400, tweet.errors.to_json
      end
    end
  end


  private

# Verifies a tweet's user is valid.
  def self.verify_tweet(user, tweet, array)
    if user
      array.push [tweet, user]
    else
      # Kill a tweet if it belongs to a user that no longer exists
      Tweet.destroy tweet[:id]
    end
  end

end