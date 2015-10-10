require_relative '../test_helper'
ENV['TEST_CYCLES'] ||= '3'
cycles = ENV['TEST_CYCLES']

class GradebookExporterTest
  def initialize
    @job = GradebookExporterJob.new(job_attrs)
  end

  def job_attrs
    { user_id: 1, course_id: 3 }
  end

  def enqueue
    @job.enqueue
  end

  def enqueue_in(time)
    @job.enqueue_in(10)
  end
end

Rails.logger.info "Starting #{cycles} GradebookExporterTest cycles..."
Rails.logger.info "Running normal enqueues, should happen right now:"
ENV['TEST_CYCLES'].to_i.times do
  GradebookExporterTest.new.enqueue
end

Rails.logger.info "Running delayed enqueue_in calls, should happen in ten seconds:"
ENV['TEST_CYCLES'].to_i.times do
  GradebookExporterTest.new.enqueue_in(10)
end
