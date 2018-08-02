require_relative "../creates_grade"

module Services
  module Actions
    class IteratesGradeAttributes
      extend LightService::Action

      expects :assignment_id, :graded_by_id, :grade_attributes
      promises :successful, :unsuccessful

      executed do |context|
        context.successful = []
        context.unsuccessful = []

        context.grade_attributes.each do |key, value|
          params = { "grade" => value }
          params.merge! "assignment_id" => context.assignment_id
          params.merge! "student_id" => value[:student_id]
          result = Services::CreatesGrade.call(params, context.graded_by_id)
          if result.success?
            context.successful << result[:grade]
          else
            context.unsuccessful << { grade: result[:grade], error: result[:message] } unless result.error_code == 400
          end
        end
      end
    end
  end
end
