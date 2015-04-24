require 'sinatra/activerecord'

require_relative '../models/user'
require_relative '../services/user_service'
require_relative '../services/tweet_service'

class LoadTestService

	def self.test_follow
		test_user = UserService.get_by_username 'test_user'
  	user_to_follow = UserService.get_by_id rand(1000)+1
  	(test_user.following? user_to_follow) ? (test_user.unfollow user_to_follow) : (test_user.follow user_to_follow)
	end

	def self.test_tweet
		test_user = UserService.get_by_username "test_user"
  	TweetService.new({text: Faker::Hacker.say_something_smart,
                      user_id: test_user[:id]
    	              })
	end

	def self.reset
		test_user = UserService.get_by_username 'test_user'
		test_user.followees.destroy_all
		test_user.tweets.destroy_all

    true
	end

end
