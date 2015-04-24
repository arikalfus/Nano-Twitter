class RedisService

  def self.cache_tweets(html_tweets, redis)
    html_tweets.each do |html|
      redis.lpush 'tweets', html
    end
  end

  def self.get_tweets(redis)
    redis.lrange 'tweets', 0, 100
  end

  def self.validate_cache(redis, key)
    redis.get(key).nil? ? false : true
  end

end