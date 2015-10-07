class ResqueJob::Performer
  # DSL improvements and resque-scheduler helpers
  def initialize(attrs={})
    @attrs = attrs
    @outcomes = []
  end

  attr_reader :outcomes

  # this is where the heavy lifting is done
  def do_the_work
    require_success do
      puts "Please define a self.start_work() method on the inheritor class to do some work."
    end
  end

  # mock out some empty work callback methods just in case
  def setup; end

  def outcome_messages
    if outcome_success?
      puts "Work was performed successfully without errors."
    elsif outcome_failure?
      puts "All of the work on the job failed to complete."
    else
      puts "Some tasks on the job failed but others succeeded."
    end
  end

  def failures
    @failures ||= @outcomes.select {|outcome| outcome.failure? }
  end

  def successes
    @successes ||= @outcomes.select {|outcome| outcome.success? }
  end

  def outcome_success?
    has_successes? and ! has_failures?
  end

  def outcome_failure?
    has_failures? and ! has_successes?
  end

  def has_failures?
    failures.size > 0
  end

  def has_successes?
    successes.size > 0
  end

  def require_success
    outcome = ResqueJob::Outcome.new(yield)
    @outcomes << outcome
    outcome
  end
end
