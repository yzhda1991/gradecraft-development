module Services
  module Actions
    class RefreshAssignment
      extend LightService::Action

      expects :assignment, :lms_assignment

      executed do |context|
        assignment = context.assignment
        lms_assignment = context.lms_assignment

        assignment.name = lms_assignment["name"]
        assignment.description = lms_assignment["description"]
        assignment.due_at = lms_assignment["due_at"]
        assignment.full_points = lms_assignment["points_possible"]
        assignment.pass_fail = true if lms_assignment["grading_type"] == "pass_fail"
        assignment.save
      end
    end
  end
end
