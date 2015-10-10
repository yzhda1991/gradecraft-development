require_relative '../test_helper'
ENV['TEST_CYCLES'] ||= '3'

class GradebookExporterTest
  def initialize(attrs={})
    @attrs = attrs || default_attrs
    fetch_sample_records
    create_job
  end
  attr_reader :job

  def create_job
    @job = GradebookExporterJob.new(job_attrs)
  end

  def job_attrs
    { user_id: @user.id, course_id: @course.id }
  end

  def default_attrs
    { user_id: 3, course_id: 1 }
  end

  def fetch_sample_records
    @user = User.find(3)
    @course = Course.find(1)
  end

  def run
    job.enqueue
  end
end

Rails.logger.info "Starting #{ENV['TEST_CYCLES']} GradebookExporterTest cycles..."
ENV['TEST_CYCLES'].to_i.times do
  GradebookExporterTest.new.run
end
