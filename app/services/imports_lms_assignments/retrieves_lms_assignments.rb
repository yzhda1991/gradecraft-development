require "active_lms"

module Services
  module Actions
    class RetrievesLMSAssignments
      extend LightService::Action

      expects :access_token, :assignment_ids, :provider, :course_id
      promises :assignments

      executed do |context|
        provider = context.provider
        access_token = context.access_token
        assignment_ids = context.assignment_ids
        course_id = context.course_id

        syllabus = ActiveLMS::Syllabus.new provider, access_token
        context.assignments = syllabus.assignments(course_id, assignment_ids) do
          context.fail!("An error occurred while attempting to retrieve #{provider} assignments", error_code: 500)
          next context
        end

        next context if context.failure?
      end
    end
  end
end
