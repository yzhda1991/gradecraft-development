module Services
  module Actions
    class AssociatesSubmissionWithGrade
      extend LightService::Action

      expects :student, :assignment, :grade

      executed do |context|
        assignment = context.assignment
        student = context.student

        if assignment.has_groups?
          group = student.group_for_assignment(assignment)
          s = Submission.find_by(assignment_id: assignment.id,
                                 group_id: group.id)
        else
          s = Submission.find_by(assignment_id: assignment.id,
                                 student_id: student.id)
        end
        context[:grade].submission_id = s.id unless s.nil?
      end
    end
  end
end
