class User < ActiveRecord::Base
  #validates_uniqueness_of :name, :email, :username, :phone

  has_many :follows, :class_name => "Follow", :foreign_key => "follower_id"
  has_many :followees, :through => :follows
  has_many :reverse_follows, :class_name => "Follow", :foreign_key => "followee_id"
  has_many :followers, :through => :reverse_follows
  has_many :tweets

  def to_json
    super(:except => :password)
  end

  def follow(other_user)
  	follows.create(followee_id: other_user[:id])
  end

  def unfollow(other_user)
  	follows.find_by(followee_id: other_user[:id]).destroy
  end

  def following?(other_user)
  	followees.include?(other_user)
  end

end