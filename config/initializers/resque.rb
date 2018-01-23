require "resque"
# throttles number of jobs being run in a queue at a time
require "resque/throttler"
require "resque-retry" # retries failed/exceptioned jobs
require "resque/failure/redis"
require "resque/server"
require 'resque-scheduler'
require 'resque/scheduler/server'

REDIS = Redis.new(:host =>  ENV["REDIS_HOST_IP"], :port => ENV["REDIS_PORT"])
Resque.redis = REDIS

Resque::Failure::MultipleWithRetrySuppression.classes = [Resque::Failure::Redis]
Resque::Failure.backend = Resque::Failure::MultipleWithRetrySuppression

# rate limits by queue

# process 20 jobs/second max
Resque.rate_limit(:pageview_event_logger, at: 20, :per => 1)

# process 2 jobs/second max
Resque.rate_limit(:login_event_logger, at: 2, :per => 1)

# process 20 jobs/second max
Resque.rate_limit(:predictor_event_logger, at: 20, :per => 1)

# scheduled jobs
Resque.schedule = YAML.load_file(Rails.root.join("config", "resque_schedule.yml"))
