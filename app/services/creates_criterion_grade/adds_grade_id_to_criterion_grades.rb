module Services
  module Actions
    class AddsGradeIdToCriterionGrades
      extend LightService::Action

      expects :criterion_grades
      expects :grade

      executed do |context|
        context[:criterion_grades].each do |cg|
          cg.grade_id = context[:grade].id
        end
      end
    end
  end
end
