require 'sinatra/activerecord'

require_relative 'models/user'

class UserService

  def self.get_by_id(id)
    User.find_by_id id
  end

  def self.get_by_username(username)
    User.find_by_username username
  end

  def self.new(params)
    begin
      user = User.create(name: params[:name],
                         email: params[:email],
                         username: params[:username],
                         password: params[:password],
                         phone: params[:phone]
      )

      if user.valid?
        user.to_json
      else
        error 400, user.errors.to_json
      end
    rescue => e
      error 400, e.message.to_json
    end
  end

  def self.get_by_username_and_password(params)
    User.find_by_username_and_password params[:username], params[:password]
  end

end