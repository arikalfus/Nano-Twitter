require 'sinatra/activerecord'
require 'json'

require_relative '../models/tweet'
require_relative 'user_service'

class TweetService

  def self.tweets_by_user_id(user_id, users=nil)
    tweets = Tweet.where(user_id: user_id).order(created_at: :desc).limit 100

    if users
      user_hash = hash_users users
      build_tweets tweets, user_hash
    else
      prepare_tweets tweets
    end

  end

  def self.tweets
    tweets = Tweet.order(created_at: :desc).limit 100
    prepare_tweets tweets
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
  def self.prepare_tweets(tweets)

    user_ids = []

    tweets.each do |tweet|
      user_ids.push tweet[:user_id]
    end
    # multi-get database call
    users = UserService.get_by_ids user_ids

    user_hash = hash_users users

    build_tweets tweets, user_hash

  end

  def self.hash_users(users)

    # To optimize full_tweet creation below
    user_hash = Hash.new
    users.each do |user|
      user_hash[user[:id]] = user
    end

  end

  def self.build_tweets(tweets, user_hash)

    full_tweets = []

    tweets.each do |tweet|
      tweet_user = user_hash[tweet[:user_id]] # should return nil if no key is found
      if tweet_user.nil?
        Tweet.destroy tweet[:id]
      else
        full_tweets.push [tweet, tweet_user]
      end
    end

    full_tweets

  end

end