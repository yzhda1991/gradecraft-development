module Services
  module Actions
    class AssociatesSubmissionWithGrade
      extend LightService::Action

      expects :student
      expects :assignment
      expects :grade

      executed do |context|
        s = Submission.where({ assignment_id: context[:assignment].id,
                               student_id: context[:student].id }).first
        context[:grade].submission_id = s.nil? ? nil : s.id
      end
    end
  end
end
