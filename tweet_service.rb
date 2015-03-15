require 'sinatra/activerecord'

require_relative 'models/tweet'

class Tweet

def self.tweets_by_user_id(user_id)
  Tweet.where(user_id: user_id).limit(25).order created_at: :desc
end

  def self.tweets
    Tweet.limit(25).order created_at: :desc
  end

end