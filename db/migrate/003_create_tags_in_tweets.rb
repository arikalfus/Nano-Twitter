class CreateTagInTweets < ActiveRecord::Migration
  def self.up
    create_table :tags_in_tweets do |t|
      t.int :tweet_id
      t.int :tag_id
    end
  end

  def self.down
    drop_table :users
  end
end
