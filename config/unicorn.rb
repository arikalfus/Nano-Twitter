worker_processes 5
timeout 30
preload_app true

before_fork do |server, worker|
  # Disconnect since the database connection will not carry over
  if defined? ActiveRecord::Base
    ActiveRecord::Base.connection.disconect!
  end
end

after_fork do |server, worker|
  # Start up the database connection again in the worker
  if defined? ActiveRecord::Base
    ActiveRecord::Base.establish_connection
  end
end