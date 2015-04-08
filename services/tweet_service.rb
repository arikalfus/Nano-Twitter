require 'sinatra/activerecord'

require_relative '../models/tweet'
require_relative 'user_service'

class TweetService

  def self.tweets_by_user_id(user_id)
    tweets = Tweet.where(user_id: user_id).limit(100).order created_at: :desc

    build_tweets tweets
  end

  def self.tweets
    tweets = Tweet.limit(100).order created_at: :desc

    build_tweets tweets
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

  # Constructs an array of [tweet, user] pairs.
  def self.build_tweets(tweets)

    user_ids = []
    full_tweets = []

    tweets.each do |tweet|
      user_ids.push tweet[:user_id]
    end
    # multi-get database call
    users = UserService.get_by_ids user_ids

    # To optimize full_tweet creation below
    user_hash = Hash.new
    users.each do |user|
      user_hash[user[:id]] = user
    end

    tweets.each do |tweet|
      tweet_user = user_hash[tweet[:user_id]] # should return nil if no key is found
      if tweet_user.nil?
        Tweet.destroy(tweet[:id])
      else
        full_tweets.push [tweet, tweet_user]
      end
    end

    full_tweets

  end

end