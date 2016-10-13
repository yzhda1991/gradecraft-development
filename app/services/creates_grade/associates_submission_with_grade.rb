module Services
  module Actions
    class AssociatesSubmissionWithGrade
      extend LightService::Action
      
      expects :student, :assignment, :grade

      executed do |context|
        if context[:group]
          s = Submission.where({ assignment_id: context[:assignment].id,
                               group_id: context[:group].id }).first
        else
          s = Submission.where({ assignment_id: context[:assignment].id,
                               student_id: context[:student].id }).first
        end
        context[:grade].submission_id = s.nil? ? nil : s.id
      end
    end
  end
end
