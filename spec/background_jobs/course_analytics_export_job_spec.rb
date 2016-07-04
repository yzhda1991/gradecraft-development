require "resque_job"
require "./app/background_jobs/course_analytics_exports_job"

describe CourseAnalyticsExportsJob do
  subject { described_class }

  it "inherits from ResqueJob::Base" do
    expect(subject.super_class).to eq ResqueJob::Base
  end

  it "uses the course_analytics_exports queue" do
  end

  it "performs the job with the CourseAnalyticsExportsPerformer" do
  end
end
