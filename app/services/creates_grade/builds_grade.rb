module Services
  module Actions
    class BuildsGrade
      extend LightService::Action

      expects :attributes
      expects :student
      expects :assignment

      promises :grade

      executed do |context|
        grade = Grade.find_or_create(context[:assignment].id,context[:student].id)
        grade.full_points = context[:assignment].full_points
        grade.raw_points = context[:attributes]["grade"]["raw_points"]
        grade.status = context[:attributes]["grade"]["status"]
        grade.feedback = context[:attributes]["grade"]["feedback"]
        grade.adjustment_points = context[:attributes]["grade"]["adjustment_points"]
        grade.adjustment_points_feedback = context[:attributes]["grade"]["adjustment_points_feedback"]
        grade.group_id = context[:attributes]["group_id"] if context[:attributes]["group_id"]
        context[:grade] = grade
      end
    end
  end
end
