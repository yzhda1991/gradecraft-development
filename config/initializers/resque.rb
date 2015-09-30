REDIS = Redis.new(:host =>  ENV['REDIS_HOST_IP'], :port => ENV['REDIS_PORT'])
Resque.redis = REDIS

# rate limits by queue
# Resque.rate_limit(:pageview_event_logger, at: 2, :per => 1) # process 2 workers/second max
# Resque.rate_limit(:predictor_event_logger, at: 5, :per => 1) # process 5 workers/second max

