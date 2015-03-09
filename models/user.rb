class User < ActiveRecord::Base
  validates_uniqueness_of :name, :email, :username, :phone

  has_many :follows, :class_name => "Follow", :foreign_key => "follower_id"
  has_many :followings, :through => :follows
  has_many :reverse_follows, :class_name => "Follow", :foreign_key => "following_id"
  has_many :followers, :through => :reverse_follows
  has_many :tweets

  def to_json
    super(:except => :password)
  end
end