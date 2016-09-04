module Services
  module Actions
    class BuildsCriterionGrades
      extend LightService::Action

      expects :raw_params
      expects :student
      expects :assignment
      promises :criterion_grades

      executed do |context|

        criterion_grades = []

        student = context[:student]
        assignment = context[:assignment]

        context[:raw_params]["criterion_grades"].each do |params|
          criterion_id = params["criterion_id"]
          cg = CriterionGrade.find_or_create(assignment.id,criterion_id,student.id)
          cg.update_attributes({points: params["points"],
                                comments: params["comments"]
                              })
          criterion_grades << cg
        end

        context[:criterion_grades] = criterion_grades
      end
    end
  end
end
