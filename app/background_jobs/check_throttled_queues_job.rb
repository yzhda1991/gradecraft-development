class CheckThrottledQueuesJob < ResqueApplicationJob
  THROTTLED_JOB_QUEUES = %w(pageview_event_logger login_event_logger predictor_event_logger).freeze

  queue_as :check_throttled_queues

  attr_reader :redis

  def initialize
    @redis = Resque.redis
  end

  def perform
    THROTTLED_JOB_QUEUES.each do |q|
      clear_queue(q) if next_job_at_or_exceeds_limit? q
    end
  end

  def clear_queue(queue)
    queue_key = "throttler:#{queue}_uuids"
    uuids = @redis.smembers(queue_key)

    while next_job_at_or_exceeds_limit? queue
      uuid = uuids.first
      @redis.srem(queue_key, uuid)
      @redis.del("throttler:jobs:#{uuid}")
      Rails.logger.debug "Deleted uuid #{uuid} from redis"
    end
  end

  def next_job_at_or_exceeds_limit?(queue)
    Resque.queue_at_or_over_rate_limit? queue
  end
end

class QueueCheckThrottledQueuesJob
  def self.perform
    CheckThrottledQueuesJob.new.perform_now
  end
end
