require 'sinatra/activerecord'

require_relative '../models/user'

class UserService

  # create a user
  def self.new(params)
    user = User.create(name: params[:name],
                       email: params[:email],
                       username: params[:username],
                       password: params[:password],
                       phone: params[:phone]
    )

    verify_user user
  end

  # get user by ID
  def self.get_by_id(id)
    user = User.find_by_id id
    verify_user user
  end

  # Get multiple users from array of ID's
   def self.get_by_ids(ids)
    User.where id: ids
   end

  # get user by username
  def self.get_by_username(username)
    user = User.find_by_username username
    verify_user user
  end

  # get user by username and password
  def self.get_by_username_and_password(params)
    user = User.find_by_username_and_password params[:username], params[:password]
    verify_user user
  end

  # search Users table for search terms in username or name
  def self.search_for(search_terms)
    users = User.where("lower(username) LIKE ?", "#{search_terms.downcase}%") | User.where("lower(name) LIKE ?", "#{search_terms.downcase}%")

    users.empty? ? nil : users
  end

  private

  # Verifies a valid user object
  def self.verify_user(user)
    if user
      if user.valid?
        user
      else
        nil
      end
    else
      nil
    end
  end

end