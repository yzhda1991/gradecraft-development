class ResqueJob::Performer
  # DSL improvements and resque-scheduler helpers
  def initialize(job_klass, attrs={})
    @attrs = attrs
    @job_klass = job_klass
    @outcome = nil
  end

  attr_reader :outcome

  # this is where the heavy lifting is done
  def do_the_work(attrs={})
    puts "Please define a self.start_work() method on the inheritor class to do some work."
    { success: true } # pass this back to @job_succeeded
  end

  # mock out some empty work callback methods just in case
  def setup; end

  def enqueue_in(time_until_start)
    Resque.enqueue_in(time_until_start, @job_klass, @attrs)
  end

  def enqueue_at(scheduled_time)
    Resque.enqueue_at(scheduled_time, @job_klass, @attrs)
  end

  def enqueue
    Resque.enqueue(@job_klass, @attrs)
  end
end
