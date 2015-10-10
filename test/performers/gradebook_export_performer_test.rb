require_relative '../test_helper'
ENV['TEST_CYCLES'] ||= '3'

class GradebookExporterTest
  def initialize
    @job = GradebookExporterJob.new(job_attrs)
  end

  def job_attrs
    { user_id: 1, course_id: 3 }
  end

  def run
    @job.enqueue
  end
end

Rails.logger.info "Starting #{ENV['TEST_CYCLES']} GradebookExporterTest cycles..."
ENV['TEST_CYCLES'].to_i.times do
  GradebookExporterTest.new.run
end
