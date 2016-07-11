require "resque_job"
require_relative "../performers/course_analytics_export_performer"

class CourseAnalyticsExportJob < ResqueJob::Base
  @queue = :course_analytics_exports
  @performer_class = CourseAnalyticsExportPerformer
end
