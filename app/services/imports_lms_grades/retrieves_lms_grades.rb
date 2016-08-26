require "active_lms"

module Services
  module Actions
    class RetrievesLMSGrades
      extend LightService::Action

      expects :access_token, :assignment_ids, :course_id, :grade_ids, :provider
      promises :grades

      executed do |context|
        provider = context.provider
        access_token = context.access_token
        assignment_ids = context.assignment_ids
        course_id = context.course_id
        grade_ids = context.grade_ids

        syllabus = ActiveLMS::Syllabus.new provider, access_token
        context.grades = syllabus.grades course_id, assignment_ids, grade_ids
      end
    end
  end
end
