require 'faker'

require_relative '../services/user_service'
require_relative '../services/tweet_service'

class LoadTestService

  # Get a random user and either follow/unfollow
	def self.test_follow
		test_user = UserService.get_by_username 'test_user'
  	user_to_follow = UserService.get_random
  	test_user.following?(user_to_follow) ? test_user.unfollow(user_to_follow) : test_user.follow(user_to_follow)
	end

	def self.test_tweet
		test_user = UserService.get_by_username "test_user"
  	tweet = TweetService.new({text: Faker::Hacker.say_something_smart,
															user_id: test_user.id
                             })
    if tweet
      tweet
    else
      error 400, tweet.errors.to_json
    end
	end

	def self.reset
		test_user = UserService.get_by_username 'test_user'
		test_user.followees.destroy_all
		test_user.tweets.destroy_all
	end

end
