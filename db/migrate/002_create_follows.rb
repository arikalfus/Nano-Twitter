class CreateFollows < ActiveRecord::Migration
  def self.up
    create_table :follows do |t|
      t.column "follower_id", :integer, :null => false
      t.column "following_id", :integer, :null => false
    end
  end

  def self.down
    drop_table :follows
  end
end