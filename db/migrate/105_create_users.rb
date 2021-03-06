class CreateUsers < ActiveRecord::Migration

  def self.up
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :username
      t.string :password
      t.string :image
      t.timestamps
      t.string :phone
    end
  end

  def self.down
    drop_table :users
  end
end


