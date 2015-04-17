class CreateTweets < ActiveRecord::Migration

  def self.up
    create_table :tweets do |t|
      t.timestamps
      t.string :text
      t.integer :user_id
    end

    add_index :tweets, :created_at
  end

  def self.down
    drop_table :tweets
  end
end