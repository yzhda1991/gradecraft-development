require "light-service"
require_relative "imports_lms_grades/imports_lms_grades"
require_relative "imports_lms_grades/retrieves_lms_grades"

module Services
  class ImportsLMSGrades
    extend LightService::Organizer

    def self.import(provider, access_token, course_id, grade_ids, assignment_id)
      with(provider: provider, access_token: access_token, course_id: course_id,
           grade_ids: grade_ids, assignment_id: assignment_id).reduce(
             Actions::RetrievesLMSGrades,
             Actions::ImportsLMSGrades
      )
    end
  end
end
