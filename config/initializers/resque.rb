require "resque"
# throttles number of jobs being run in a queue at a time
require "resque/throttler"
require "resque-retry" # retries failed/exceptioned jobs
require "resque/failure/redis"

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

# these are the steps that will be used when
RESQUE_CONFIG = {
  "BACKOFF_STRATEGY" => [
    0, 15, 30, 45, 60, 90, 120, 150, 180, 240, 300, 360, 420, 540, 660, 780,
    900, 1_140, 1_380, 1_520, 1_760, 3_600, 7_200, 14_400, 28_800
  ]
}
