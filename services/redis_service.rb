class RedisService

  # Cache tweet html strings
  def self.cache_tweets(html_tweets, redis)
    html_tweets.each do |html|
      redis.rpush 'tweets', html
    end
  end

  # Get first 100 tweets from cache
  def self.get_tweets(redis)
    redis.lrange 'tweets', 0, 100
  end

  # Test if there is content in the cache
  def self.validate_cache(redis, key)
    redis.lrange('tweets', 0, 1).empty? ? false : true
  end

  # Add tweet to front of cache, pop oldest tweet from cache
  def self.cache(tweet, redis)
    redis.multi do
      redis.lpush 'tweets', tweet
      redis.rpop 'tweets'
    end
  end

end