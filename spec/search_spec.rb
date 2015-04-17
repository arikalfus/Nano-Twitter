require_relative 'spec_helper'

describe 'using the search bar' do

  def app
    Sinatra::Application
  end

  before :all do
    User.delete_all
    Tweet.delete_all
    Follow.delete_all

    @browser = Rack::Test::Session.new(Rack::MockSession.new(app))
  end


end