class CourseAnalyticsExportsJob < ResqueJob::Base
  @queue = :course_analytics_exports
  @performer_class = CourseAnalyticsExportsPerformer
end
