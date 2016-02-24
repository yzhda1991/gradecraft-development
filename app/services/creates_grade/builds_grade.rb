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
        grade.raw_score = context[:attributes]["points_given"]
        grade.point_total = context[:assignment].point_total
        grade.status = context[:attributes]["grade"]["status"]
        grade.feedback = context[:attributes]["grade"]["feedback"]
        grade.group_id = context[:attributes]["group_id"] \
          if context[:attributes]["group_id"]
        context[:grade] = grade
      end
    end
  end
end
