module BackgroundJobs
  def run_background_jobs_immediately
    allow(Resque).to receive(:enqueue).and_call_original
    inline = Resque.inline
    Resque.inline = true
    yield
  ensure
    Resque.inline = inline
  end
end
