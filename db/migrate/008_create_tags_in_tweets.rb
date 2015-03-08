class CreateTagsInTweets < ActiveRecord::Migration
  def self.up
    create_table :tags_in_tweets do |t|
      t.integer :tweet_id
      t.integer :tag_id
    end
  end

  def self.down
    drop_table :users
  end
end
