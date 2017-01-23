module Services
  module Actions
    class BuildsGrade
      extend LightService::Action

      expects :attributes, :student, :assignment, :graded_by_id
      promises :grade

      executed do |context|
        grade = Grade.find_or_create(context[:assignment].id, context[:student].id)
        update_grade_attributes grade, context[:attributes]["grade"]
        grade.assign_attributes context[:attributes]["grade"]
        grade.graded_at = DateTime.now
        grade.graded_by_id = context[:graded_by_id]
        grade.full_points = context[:assignment].full_points
        grade.group_id = context[:attributes]["group_id"] if context[:attributes]["group_id"]
        context[:grade] = grade
      end
    end
  end
end
