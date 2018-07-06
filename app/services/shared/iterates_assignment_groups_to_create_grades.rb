require_relative "../creates_group_grades"

module Services
  module Actions
    class IteratesAssignmentGroupsToCreateGrades
      extend LightService::Action

      expects :assignment_id, :grades_by_group_params, :graded_by_id
      promises :unsuccessful, :successful

      executed do |context|
        context.successful = []
        context.unsuccessful = []
        grades_by_group_params = context[:grades_by_group_params]
        assignment_id = context[:assignment_id]
        graded_by_id = context[:graded_by_id]

        grades_by_group_params[:grades_by_group].each do |index, gbg|
          result = Services::CreatesGroupGrades.call gbg[:group_id], gbg, assignment_id, graded_by_id
          if result.success?
            context.successful << result[:grade]
          else
            context.unsuccessful << { grade: result[:grade], error: result[:message] }
          end
        end
      end
    end
  end
end
