require 'sinatra/activerecord'

require_relative '../models/user'

class UserService

  def self.get_by_id(id)
    user = User.find_by_id id
    verify_user user
  end

  # def self.get_by_ids(ids)
  #   users = User.find_by_id ids
  #   users
  # end

  def self.get_by_username(username)
    user = User.find_by_username username
    verify_user user
  end

  def self.new(params)7
    user = User.create(name: params[:name],
                       email: params[:email],
                       username: params[:username],
                       password: params[:password],
                       phone: params[:phone]
    )

    verify_user user
  end

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