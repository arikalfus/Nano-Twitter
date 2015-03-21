# Rake defines developer "tasks" to automate various typical activities

require './app'
require 'sinatra/activerecord/rake'
require 'rake/testtask'


Rake::TestTask.new do |t|
  t.pattern = 'spec/*_spec.rb'
  t.verbose = true
end