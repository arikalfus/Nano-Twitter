require 'sinatra/activerecord'

require_relative '../models/user'

class UserService

  #create a user
  def self.new(params)
    user = User.create(name: params[:name],
                       email: params[:email],
                       username: params[:username],
                       password: params[:password],
                       phone: params[:phone]
    )

    verify_user user
  end

  #get user by ID
  def self.get_by_id(id)
    user = User.find_by_id id
    verify_user user
  end

   def self.get_by_ids(ids)
    #ids.each do |i|
    users = User.where id: ids
    users
   end

  #get user by username
  def self.get_by_username(username)
    user = User.find_by_username username
    verify_user user
  end

  #get user by username and password
  def self.get_by_username_and_password(params)
    user = User.find_by_username_and_password params[:username], params[:password]
    verify_user user
  end

  private

  def self.verify_user(user)
    if user
      user.valid? ? user : nil
    else
      nil
    end
  end

end