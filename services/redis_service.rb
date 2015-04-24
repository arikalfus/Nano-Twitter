require 'json'

class RedisService

  def self.cache_tweets(html_tweets, redis)
    redis.set 'tweets', html_tweets.to_json
  end

  def self.get_tweets(redis)
    JSON.parse redis.get('tweets')
  end

  def self.validate_cache(redis, key)
    redis.get(key).nil? ? false : true
  end

end