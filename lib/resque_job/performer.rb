class ResqueJob::Performer
  # DSL improvements and resque-scheduler helpers
  def initialize(attrs={})
    @attrs = attrs
    @outcomes = []
    @outcome_messages = []
    setup
  end

  attr_reader :outcomes, :outcome_messages

  # this is where the heavy lifting is done
  def do_the_work
    require_success do
      puts "Please define a self.start_work() method on the inheritor class to do some work."
    end
  end

  # mock out some empty work callback methods just in case
  def setup; end

  def add_message(message)
    @outcome_messages << message
  end

  def add_outcome_messages(outcome, messages={})
    add_message(messages[:success]) if messages[:success] and outcome.success?
    add_message(messages[:failure]) if messages[:failure] and outcome.failure?
  end

  def puts_outcome_messages
    @outcome_messages.each {|message| puts message } 
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

  def require_success(messages={})
    outcome = ResqueJob::Outcome.new(yield || false)
    add_outcome_messages(outcome, messages) unless messages == {}
    @outcomes << outcome
    outcome
  end
end
