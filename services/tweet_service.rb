require 'sinatra/activerecord'
require 'json'

require_relative '../models/tweet'
require_relative 'user_service'

class TweetService

  # Get most recent 100 tweets of user_id (may be an array of ID's).
  # If passed a user object, bypass #prepare_tweets and go directly to #build_tweets.
  #
  # see #prepare_tweets, #build_tweets, and #hash_users
  def self.tweets_by_user_id(user_id, users=nil)

    tweets = Tweet.where(user_id: user_id).order(created_at: :desc).limit 100
    if users # skip call to database if we already have the user objects
      user_hash = hash_users users
      build_tweets tweets, user_hash
    else
      prepare_tweets tweets
    end

  end

  # Get most recent 100 tweets
  #
  # see #prepare_tweets
  def self.tweets
    tweets = Tweet.order(created_at: :desc).limit 100
    prepare_tweets tweets
  end

  # Store a new tweet in database.
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

  # Gets user objects of tweets.
  #
  # See #hash_users and #build_tweets
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

  # Constructs a hash of user objects whose keys are user IDs.
  #
  # Optimizes #build_tweet method. Discernible performance improvement
  def self.hash_users(users)

    user_hash = Hash.new
    users.each { |user| user_hash[user[:id]] = user }

    user_hash

  end

  # Constructs an array of [tweet, user] pairs.
  def self.build_tweets(tweets, user_hash)

    full_tweets = []

    tweets.each do |tweet|
      tweet_user = user_hash[tweet[:user_id]]
      full_tweets.push [tweet, tweet_user] unless tweet_user.nil?
    end

    full_tweets

  end

end