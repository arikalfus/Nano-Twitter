class User < ActiveRecord::Base
  validates_uniqueness_of :name, :email, :username, :phone

  has_many :follows, :class_name => "Follows", :foreign_key => "follower_id"
  has_many :followings, :through => :follows
  has_many :follows, :class_name => "Follows", :foreign_key => "following_id"
  has_many :followers, :through => :follows

  def to_json
    super(:except => :password)
  end
end