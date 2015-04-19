class CreateTweets < ActiveRecord::Migration

  def self.up
    create_table :tweets do |t|
      t.timestamps
      t.string :text
      t.integer :user_id
    end

    add_index :tweets, :created_at, order: {created_at: :desc}
    add_index :tweets, :updated_at, order: {updated_at: :desc}
  end

  def self.down
    drop_table :tweets
  end
end