module Services
  module Actions
    class BuildsGrade
      extend LightService::Action

      expects :attributes
      expects :student
      expects :assignment

      promises :grade

      executed do |context|
        grade = Grade.find_or_create(context[:assignment],context[:student])

        grade.raw_score = context[:attributes]["points_given"]
        grade.point_total = context[:assignment].point_total
        grade.status =  context[:attributes]["grade_status"]

        context[:grade] = grade
      end
    end
  end
end
