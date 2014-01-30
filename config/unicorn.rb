# If you have a very small app you may be able to
# increase this, but in general 3 workers seems to
# work best
worker_processes 3

# Load your app into the master before forking
# workers for super-fast worker spawn times
preload_app true

# Immediately restart any workers that
# haven't responded within 31 seconds
timeout 31

before_fork do |server, worker|
  # Replace with MongoDB or whatever
  
  # since this shares its DB connection with rails 
  if defined?(QC)
    QC::Conn.disconnect
  end
  
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end
 
   
  # If you are using Redis but not Resque, change this
  if defined?(Resque)
    Resque.redis.quit
  end
 
  sleep 1
end
 
after_fork do |server, worker|

  # Replace with MongoDB or whatever
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
 
  if defined?(QC)
    QC::Conn.connection = ActiveRecord::Base.connection.raw_connection
  end
  
 
  # If you are using Redis but not Resque, change this
  if defined?(Resque)
    Resque.redis = ENV['REDIS_URI']
  end
end