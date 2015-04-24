class RedisService

  def self.cache_tweets(html_tweets, redis)
    binding.pry
    html_tweets.each do |html|
      redis.rpush 'tweets', html
    end
  end

  def self.get_tweets(redis)
    redis.lrange 'tweets', 0, 100
  end

  def self.validate_cache(redis, key)
    redis.lrange('tweets', 0, 1).empty? ? false : true
  end

end