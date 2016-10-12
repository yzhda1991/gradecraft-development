require_relative "../creates_grade_using_rubric"

module Services
  module Actions
    class IteratesAssignmentGroupsToCreateGrades
      extend LightService::Action

      expects :assignment_id
      expects :grades_by_group_params
      expects :graded_by_id

      promises :unsuccessful
      promises :successful

      executed do |context|
        context.successful = []
        context.unsuccessful = []
        grades_by_group_params = context[:grades_by_group_params]
        assignment_id = context[:assignment_id]
        graded_by_id = context[:graded_by_id]

        grades_by_group_params[:grades_by_group].each do |index, gbg|
          result = Services::CreatesGroupGrades.create gbg[:group_id], gbg, assignment_id, graded_by_id
          if result.success?
            context.successful << result[:grade]
          else
            context.unsuccessful << { grade: result[:grade], error: result[:error_code] }
          end
        end
      end
    end
  end
end
