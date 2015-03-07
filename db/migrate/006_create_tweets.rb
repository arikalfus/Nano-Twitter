class CreateTweets < ActiveRecord::Migration
  def self.up
    create_table :tweets do |t|
      t.timestamps :timestamp
      t.string :text
      t.belongs_to :user
    end
  end

  def self.down
    drop_table :tweets
  end
end