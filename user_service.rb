require 'sinatra/activerecord'

require_relative 'models/user'

class UserService

  #create a user
  def self.new(params)
    user = User.create(name: params[:name],
                       email: params[:email],
                       username: params[:username],
                       password: params[:password],
                       phone: params[:phone]
    )

    if user
      user
    else
      {:status => 404, :message => "user not found"}
    end
  end

  #get user by ID
  def self.get_by_id(id)
    user = User.find_by_id id
<<<<<<< HEAD

    if user
      {:status => 200, :body => user }
    else
      {:status => 404, :message => "user not found"}
    end
=======
    verify_user user
>>>>>>> master
  end

  #get user by username
  def self.get_by_username(username)
    user = User.find_by_username username
<<<<<<< HEAD

    if user
      user
    else
      {:status => 404, :message => "user not found"}
    end
=======
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
>>>>>>> master
  end

  #get user by username and password
  def self.get_by_username_and_password(params)
    user = User.find_by_username_and_password params[:username], params[:password]
<<<<<<< HEAD

    if user
      user
    else
      {:status => 404, :message => "user not found"}
    end
  end

  def self.verify(user)
    user.status == 200 ? user[:body] : nil
=======
    verify_user user
  end

  private

  def self.verify_user(user)
    if user
      user.valid? ? user : nil
    else
      nil
    end
>>>>>>> master
  end

end