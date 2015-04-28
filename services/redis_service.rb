class RedisService

  # Cache tweet html strings
  def self.cache_tweets(html_tweets, redis)
    html_tweets.each do |html|
      redis.rpush 'tweets', html
    end
  end

  # Get first 100 tweets from cache at specified key
  def self.get_100_tweets(key, redis)
    redis.lrange key, 0, 99 # first 100 is 0-99
  end

  # Test if there is content in the cache
  def self.validate_cache(key, redis)
    redis.lrange(key, 0, 1).empty? ? false : true
  end

  # Add tweet to front of cache, pop oldest tweet from cache
  def self.cache(tweet, key, redis)
    redis.lpush key, tweet
    redis.rpop key
  end

end