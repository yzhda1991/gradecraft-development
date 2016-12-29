require "active_lms"

module Services
  module Actions
    class UpdatesLMSAssignment
      extend LightService::Action

      expects :access_token, :imported_assignment, :provider
      promises :lms_assignment

      executed do |context|
        provider = context.provider
        access_token = context.access_token
        course_id = context.imported_assignment.provider_data["course_id"]
        assignment_id = context.imported_assignment.provider_resource_id
        assignment = context.imported_assignment.assignment
        params = { assignment: { name: assignment.name,
                                 description: assignment.description,
                                 due_at: assignment.due_at.nil? ? nil :
                                         assignment.due_at.iso8601,
                                 points_possible: assignment.full_points }}
        params[:assignment].merge!(grading_type: "pass_fail") if assignment.pass_fail?

        context.lms_assignment = nil

        syllabus = ActiveLMS::Syllabus.new provider, access_token
        begin
          context.lms_assignment = syllabus.update_assignment course_id,
            assignment_id,
            params
        rescue StandardError => e
          context.fail! e.message
        end
      end
    end
  end
end
