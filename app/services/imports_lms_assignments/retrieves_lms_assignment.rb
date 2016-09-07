require "active_lms"

module Services
  module Actions
    class RetrievesLMSAssignment
      extend LightService::Action

      expects :access_token, :imported_assignment, :provider
      promises :lms_assignment

      executed do |context|
        provider = context.provider
        access_token = context.access_token
        course_id = context.imported_assignment.provider_data["course_id"]
        assignment_id = context.imported_assignment.provider_resource_id

        context.lms_assignment = nil

        syllabus = ActiveLMS::Syllabus.new provider, access_token
        begin
          context.lms_assignment = syllabus.assignment course_id, assignment_id
        rescue StandardError => e
          context.fail! e.message
        end
      end
    end
  end
end
