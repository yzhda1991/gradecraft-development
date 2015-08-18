module BackgroundJobs
  def run_background_jobs_immediately
    Resque.inline do
      yield
    end
  end
end
