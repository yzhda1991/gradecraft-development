# Maintenance

## Resque Maintenance

### Processing Stuck Jobs

There are three queues (`pageview_event_logger`, `login_event_logger`, and `predictor_event_logger`) that are "throttled". This means that they are processed at a specific rate (e.g. 20 per second).

If these queues get backed up (queues have a lot of pending jobs), there is a chance that they stay backed up unless "kick started" manually. This is because the last job that the throttler checked will always be after the last end time.

In order to kick start, you can perform the following steps:

1. Log onto the production Resque container
2. Check if the queue is throttled

```
queue = "login_event_logger"
Resque.queue_at_or_over_rate_limit?(queue)
```

3. If it returns true, you can get the first stuck job and delete it from the throttle list (using `queue` from above):

```
redis = Resque.redis
queue_key = "throttler:#{queue}_uuids"
uuids = redis.smembers(queue_key)
uuid = uuids.first
redis.srem(queue_key, uuid)
redis.del("throttler:jobs:#{uuid}")
```

4. You can then continue to check the queue with Resque.size(queue) and it should start going down
