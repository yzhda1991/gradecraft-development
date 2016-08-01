require "resque_job"
require "./app/background_jobs/course_analytics_export_job"

describe CourseAnalyticsExportJob do
  subject { described_class }

  it "inherits from ResqueJob::Base" do
    expect(subject.superclass).to eq ResqueJob::Base
  end

  it "uses the course_analytics_exports queue" do
    expect(subject.queue).to eq :course_analytics_exports
  end

  it "performs the job with the CourseAnalyticsExportPerformer" do
    expect(subject.performer_class).to eq CourseAnalyticsExportPerformer
  end
end
