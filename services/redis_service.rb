class RedisService

  def self.cache_tweets(html_tweets, redis)
    redis.set 'tweets', html_tweets
  end

  def self.get_tweets(redis)
    redis.get 'tweets'
  end

  def self.validate_cache(redis, key)
    redis.get(key).nil? ? false : true
  end

end