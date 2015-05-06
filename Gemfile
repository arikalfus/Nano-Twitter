source 'https://www.rubygems.org'
ruby '2.2.2'

gem 'rerun'
gem 'sinatra'
gem 'activerecord'
gem 'sinatra-activerecord'
gem 'sinatra-formkeeper'
gem 'json'
# gem 'newrelic_rpm'
gem 'faker'
gem 'redis'
gem 'hiredis'

group :development, :test do
  gem 'sqlite3'
  gem 'rack-test'
  gem 'minitest'
  gem 'pry-byebug'
end

group :production do
  gem 'pg'
  gem 'unicorn'
  gem 'unicorn-worker-killer'
end