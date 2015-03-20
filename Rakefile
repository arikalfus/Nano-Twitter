# Rake defines developer "tasks" to automate various typical activities

require './app'
require 'sinatra/activerecord/rake'
require 'rspec/core/rake_task'


RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = Dir.glob 'spec/*_spec.rb'
  t.verbose = true
end

task :default => :spec