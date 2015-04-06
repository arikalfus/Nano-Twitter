require 'sinatra/activerecord'

require_relative '../models/tweet'
require_relative '../models/user'

class TweetService

def self.tweets_by_user_id(user_id)
  tweets = Tweet.where(user_id: user_id).limit(100).order created_at: :desc
  full_tweets = []
   user_ids = []
   tweets.each do |tweet|
     user_ids.push tweet[:user_id]
   end
   #puts "users: #{user_ids}"
   users = UserService.get_by_ids user_ids
   #puts "user ids: #{users}"
  
   tweets.each do |tweet|
    users.each do |user|
      puts user.class
    end
    x = users.bsearch {|user| user[:id] == tweet[:user_id]}
    verify_tweet x, tweet, full_tweets
   end



   #for i in 0...tweets.count
   # users.bsearch{|user| user[:id] == tweet}
  #
   # verify_tweet users[i], tweets[i], full_tweets
   #end
  #tweets.each do |tweet|
  #  user = User.find_by_id tweet[:user_id]
  #  verify_tweet user, tweet, full_tweets
  #end

    full_tweets
  end

  def self.tweets
    tweets = Tweet.limit(100).order created_at: :desc
    full_tweets = []
    tweets.each do |tweet|
      user = User.find_by_id tweet[:user_id]
      verify_tweet user, tweet, full_tweets
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