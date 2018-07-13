class CreatedCoursesMailerJob < ResqueApplicationJob
  queue_as :created_courses_export

  def perform
    csv = CreatedCoursesExporter.new.export
    NotificationMailer.created_courses_export(csv).deliver_now
  end
end

# Used by resque_scheduler for scheduling as a recurring job
class QueueCreatedCoursesMailerJob
  def self.perform
    CreatedCoursesMailerJob.new.perform_now
  end
end
