module Backstacks
  module RetryFailedJob
    def on_failure_retry(exception, *args)
      Resque.enqueue self, *args
    end
  end
end
