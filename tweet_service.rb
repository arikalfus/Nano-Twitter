require 'sinatra/activerecord'

require_relative 'models/tweet'
require_relative 'models/user'

class TweetService

<<<<<<< HEAD
  def self.tweets_by_user_id(user_id)
    tweets = Tweet.where(user_id: user_id).limit(25).order created_at: :desc
    full_tweets = []
    tweets.each do |tweet|
      user = User.find_by_id tweet[:user_id]
      if user
        full_tweets.push [tweet, user]
      else
        # Kill a tweet if it belongs to a user that no longer exists
        Tweet.destroy tweet
      end
    end
=======
def self.tweets_by_user_id(user_id)
  tweets = Tweet.where(user_id: user_id).limit(100).order created_at: :desc
  full_tweets = []
  tweets.each do |tweet|
    user = User.find_by_id tweet[:user_id]
    verify_tweet user, tweet, full_tweets
  end
>>>>>>> master

    full_tweets
  end

  def self.tweets
    tweets = Tweet.limit(100).order created_at: :desc
    full_tweets = []
    tweets.each do |tweet|
      user = User.find_by_id tweet[:user_id]
<<<<<<< HEAD
      if user
        full_tweets.push [tweet, user]
      else
        # Kill a tweet if it belongs to a user that no longer exists
        Tweet.destroy tweet
      end
=======
      verify_tweet user, tweet, full_tweets
>>>>>>> master
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
        tweet.to_json
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