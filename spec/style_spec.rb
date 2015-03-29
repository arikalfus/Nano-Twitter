require_relative 'spec_helper'

describe 'static loading' do

	def app
		Sinatra::Application
	end

	before do
		@browser = Rack::Test::Session.new(Rack::MockSession.new(app))
	end

	it 'loads the boostrap css file' do
		@browser.get '/css/bootstrap.min.css'
		assert @browser.last_response.ok?, 'Last response is not ok'
		refute @browser.last_response.body.empty?, 'Body is empty - file not loaded'
	end

	it 'loads the jquery js file' do
		@browser.get '/js/jquery-2.1.3.min.js'
		assert @browser.last_response.ok?, 'Last response is not ok'
		refute @browser.last_response.body.empty?, 'Body is empty - file not loaded'
	end

	it 'loads the bootstrap js file' do
		@browser.get '/js/bootstrap.min.js'
		assert @browser.last_response.ok?, 'Last response is not ok'
		refute @browser.last_response.body.empty?, 'Body is empty - file not loaded'
	end

	it 'loads the background image' do
		@browser.get 'img/crossword.png'
		assert @browser.last_response.ok?, 'Last response is not ok'
		refute @browser.last_response.body.empty?, 'Body is empty - file not loaded'
	end

end