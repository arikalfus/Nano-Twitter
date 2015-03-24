require_relative 'spec_helper'

describe "/user/* URI's" do

  def app
    Sinatra::Application
  end

  before :each do
    User.delete_all
    Tweet.delete_all
    Follow.delete_all

    @browser = Rack::Test::Session.new(Rack::MockSession.new(app))
  end

  describe  'get /nanotwitter/v1.0/users/:username' do
    before do
      @test_session_user = User.create({ name: 'Jerry Test',
                                         username: 'jertest4',
                                         password: 'jerrypass',
                                         phone: 1234567890,
                                       })
      @test_user = User.create({ name: 'Terry Jest',
                                 username: 'terjest4',
                                 password: 'terrypass',
                                 phone: 1234567891,
                               })

      # Log in user
      @browser.post '/nanotwitter/v1.0/users/session', { :username => 'jertest4', :password => 'jerrypass' }
      @browser.follow_redirect!
    end

    it 'should load the user page of logged in user' do
      @browser.get '/nanotwitter/v1.0/users/jertest4'
      assert @browser.last_response.ok?, 'Last response was not ok'
      assert @browser.last_request.env['rack.session'][:user].must_equal @test_session_user[:id], "ID's are not equal"

      html_text = @browser.last_response.body.pretty_inspect
      assert html_text.must_include('maxlength=\"140\"'), "'Maxlength' was not found"
    end

    it 'should load another user page' do
      @browser.get '/nanotwitter/v1.0/users/terjest4'
      assert @browser.last_response.ok?, 'Last response is not ok'

      html_text = @browser.last_response.body.pretty_inspect
      assert html_text.must_include('Follow'), "'Follow' was not found"
    end
  end

  describe 'POST on /nanotwitter/v1.0/users' do

    it 'should create a new user with valid credentials' do
      @browser.post '/nanotwitter/v1.0/users', {
                                                 :name => 'Aviv Dev',
                                                 :email => 'Aviv@Devdev.com',
                                                 :username => 'AvivDev',
                                                 :password => '33d321421',
                                                 :password2 => '33d321421',
                                                 :phone => 4453239920
                                             }
      assert_nil @browser.last_request.env['rack.session'][:reg_error], ':reg_error is not nil'
      assert @browser.last_response.location.must_equal 'http://example.org/', 'Redirect location is not root'
      @browser.follow_redirect!
      assert @browser.last_response.ok?, 'Last response is not ok'
    end

    it 'should create a new user with empty name' do
      @browser.post '/nanotwitter/v1.0/users', {
                                                 :name => '',
                                                 :email => 'AvivDev@dev.com',
                                                 :username => 'AvivDev',
                                                 :password => '33d321421',
                                                 :password2 => '33d321421',
                                                 :phone => 4453239920
                                             }
      assert_includes @browser.last_request.env['rack.session'][:reg_error][:error_codes], 'r-n'
      assert @browser.last_response.location.must_equal 'http://example.org/', 'Redirect location is not root'
      @browser.follow_redirect!
      assert @browser.last_response.ok?, 'Last response is not ok'
    end

    it 'should create a new user with invalid name' do
      @browser.post '/nanotwitter/v1.0/users', {
                                                 :name => 'Aviv ♣ Dev',
                                                 :email => 'AvivDev@dev.com',
                                                 :username => 'AvivDev',
                                                 :password => '33d321421',
                                                 :password2 => '33d321421',
                                                 :phone => 4453239920
                                             }
      assert_includes @browser.last_request.env['rack.session'][:reg_error][:error_codes], 'r-nalpha'
      assert @browser.last_response.location.must_equal 'http://example.org/', 'Redirect location is not root'
      @browser.follow_redirect!
      assert @browser.last_response.ok?, 'Last response is not ok'
    end

    it 'should create a new user with empty email' do
      @browser.post '/nanotwitter/v1.0/users', {
                                                 :name => 'Aviv Dev',
                                                 :email => '',
                                                 :username => 'AvivDev',
                                                 :password => '33d321421',
                                                 :password2 => '33d321421',
                                                 :phone => 4453239920
                                             }
      assert_includes @browser.last_request.env['rack.session'][:reg_error][:error_codes], 'r-e'
      assert @browser.last_response.location.must_equal 'http://example.org/', 'Redirect location is not root'
      @browser.follow_redirect!
      assert @browser.last_response.ok?, 'Last response is not ok'
    end

    it 'should create a new user with invalid email' do
      @browser.post '/nanotwitter/v1.0/users', {
                                                 :name => 'Aviv Dev',
                                                 :email => 'AvivDevdev.com',
                                                 :username => 'AvivDev',
                                                 :password => '33d321421',
                                                 :password2 => '33d321421',
                                                 :phone => 4453239920
                                             }
      assert_includes @browser.last_request.env['rack.session'][:reg_error][:error_codes], 'r-einvalid'
      assert @browser.last_response.location.must_equal 'http://example.org/', 'Redirect location is not root'
      @browser.follow_redirect!
      assert @browser.last_response.ok?, 'Last response is not ok'
    end

    it 'should create a new user with empty username' do
      @browser.post '/nanotwitter/v1.0/users', {
                                                 :name => 'Aviv Dev',
                                                 :email => 'AvivDev@dev.com',
                                                 :username => '',
                                                 :password => '33d321421',
                                                 :password2 => '33d321421',
                                                 :phone => 4453239920
                                             }
      assert_includes @browser.last_request.env['rack.session'][:reg_error][:error_codes], 'r-u'
      assert @browser.last_response.location.must_equal 'http://example.org/', 'Redirect location is not root'
      @browser.follow_redirect!
      assert @browser.last_response.ok?, 'Last response is not ok'
    end

    it 'should create a new user with invalid username' do
      @browser.post '/nanotwitter/v1.0/users', {
                                                 :name => 'Aviv Dev',
                                                 :email => 'AvivDev@dev.com',
                                                 :username => 'Aviv♠Dev',
                                                 :password => '33d321421',
                                                 :password2 => '33d321421',
                                                 :phone => 4453239920
                                             }
      assert_includes @browser.last_request.env['rack.session'][:reg_error][:error_codes], 'r-uascii'
      assert @browser.last_response.location.must_equal 'http://example.org/', 'Redirect location is not root'
      @browser.follow_redirect!
      assert @browser.last_response.ok?, 'Last response is not ok'
    end

    it 'should create a new user with empty password' do
      @browser.post '/nanotwitter/v1.0/users', {
                                                 :name => 'Aviv Dev',
                                                 :email => 'AvivDev@dev.com',
                                                 :username => 'AvivDev',
                                                 :password => '',
                                                 :password2 => '33d321421',
                                                 :phone => 4453239920
                                             }
      assert_includes @browser.last_request.env['rack.session'][:reg_error][:error_codes], 'r-p'
      assert @browser.last_response.location.must_equal 'http://example.org/', 'Redirect location is not root'
      @browser.follow_redirect!
      assert @browser.last_response.ok?, 'Last response is not ok'
    end

    it 'should create a new user with invalid password' do
      @browser.post '/nanotwitter/v1.0/users', {
                                                 :name => 'Aviv Dev',
                                                 :email => 'AvivDev@dev.com',
                                                 :username => 'AvivDev',
                                                 :password => '33d32♠1421',
                                                 :password2 => '33d321421',
                                                 :phone => 4453239920
                                             }
      assert_includes @browser.last_request.env['rack.session'][:reg_error][:error_codes], 'r-pascii'
      assert @browser.last_response.location.must_equal 'http://example.org/', 'Redirect location is not root'
      @browser.follow_redirect!
      assert @browser.last_response.ok?, 'Last response is not ok'
    end

    it 'should create a new user with empty password2' do
      @browser.post '/nanotwitter/v1.0/users', {
                                                 :name => 'Aviv Dev',
                                                 :email => 'AvivDev@dev.com',
                                                 :username => 'AvivDev',
                                                 :password => '33d321421',
                                                 :password2 => '',
                                                 :phone => 4453239920
                                             }
      assert_includes @browser.last_request.env['rack.session'][:reg_error][:error_codes], 'r-p2'
      assert @browser.last_response.location.must_equal 'http://example.org/', 'Redirect location is not root'
      @browser.follow_redirect!
      assert @browser.last_response.ok?, 'Last response is not ok'
    end

    it 'should create a new user with invalid password length' do
      @browser.post '/nanotwitter/v1.0/users', {
                                                 :name => 'Aviv Dev',
                                                 :email => 'AvivDev@dev.com',
                                                 :username => 'AvivDev',
                                                 :password => '321',
                                                 :password2 => '33d321421',
                                                 :phone => 4453239920
                                             }
      assert_includes @browser.last_request.env['rack.session'][:reg_error][:error_codes], 'r-pl'
      assert @browser.last_response.location.must_equal 'http://example.org/', 'Redirect location is not root'
      @browser.follow_redirect!
      assert @browser.last_response.ok?, 'Last response is not ok'
    end

    it 'should create a new user with non-matching passwords' do
      @browser.post '/nanotwitter/v1.0/users', {
                                                 :name => 'Aviv Dev',
                                                 :email => 'AvivDev@dev.com',
                                                 :username => 'AvivDev',
                                                 :password => '3333211111143421',
                                                 :password2 => '33d321421',
                                                 :phone => 4453239920
                                             }
      assert_includes @browser.last_request.env['rack.session'][:reg_error][:error_codes], 'r-pns'
      assert @browser.last_response.location.must_equal 'http://example.org/', 'Redirect location is not root'
      @browser.follow_redirect!
      assert @browser.last_response.ok?, 'Last response is not ok'
    end

    it 'should create a new user with empty phone' do
      @browser.post '/nanotwitter/v1.0/users', {
                                                 :name => 'Aviv Dev',
                                                 :email => 'AvivDev@dev.com',
                                                 :username => 'AvivDev',
                                                 :password => '33d321421',
                                                 :password2 => '33d321421',
                                                 :phone => ''
                                             }
      assert_includes @browser.last_request.env['rack.session'][:reg_error][:error_codes], 'r-ph'
      assert @browser.last_response.location.must_equal 'http://example.org/', 'Redirect location is not root'
      @browser.follow_redirect!
      assert @browser.last_response.ok?, 'Last response is not ok'
    end

    it 'should create a new user with invalid phone characters' do
      @browser.post '/nanotwitter/v1.0/users', {
                                                 :name => 'Aviv Dev',
                                                 :email => 'AvivDev@dev.com',
                                                 :username => 'AvivDev',
                                                 :password => '33d321421',
                                                 :password2 => '33d321421',
                                                 :phone => '44533534a3'
                                             }
      assert_includes @browser.last_request.env['rack.session'][:reg_error][:error_codes], 'r-phint'
      assert @browser.last_response.location.must_equal 'http://example.org/', 'Redirect location is not root'
      @browser.follow_redirect!
      assert @browser.last_response.ok?, 'Last response is not ok'
    end

    it 'should create a new user with invalid phone length' do
      @browser.post '/nanotwitter/v1.0/users', {
                                                 :name => 'Aviv Dev',
                                                 :email => 'AvivDev@dev.com',
                                                 :username => 'AvivDev',
                                                 :password => '33d321421',
                                                 :password2 => '33d321421',
                                                 :phone => '445335343'
                                             }
      assert_includes @browser.last_request.env['rack.session'][:reg_error][:error_codes], 'r-phl'
      assert @browser.last_response.location.must_equal 'http://example.org/', 'Redirect location is not root'
      @browser.follow_redirect!
      assert @browser.last_response.ok?, 'Last response is not ok'
    end

  end

end