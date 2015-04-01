class CreateFollows < ActiveRecord::Migration
  def self.up
    create_table :follows do |t|
      t.integer "follower_id"
      t.integer "followee_id"
    end

    add_index :follows, :follower_id
    add_index :follows, :followee_id
    add_index :follows, [:follower_id, :followee_id], unique: true
  end

  def self.down
    drop_table :follows
  end
end