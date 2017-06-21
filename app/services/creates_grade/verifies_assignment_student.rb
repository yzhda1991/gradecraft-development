module Services
  module Actions
    class VerifiesAssignmentStudent
      extend LightService::Action

      expects :raw_params
      promises :student, :assignment

      executed do |context|
        begin
          context[:assignment] = Assignment.find(context[:raw_params]["assignment_id"])
          context[:student] = User.find(context[:raw_params]["student_id"])
        rescue ActiveRecord::RecordNotFound
          context.fail_with_rollback!("Unable to verify both student and assignment", error_code: 404)
        end
      end
    end
  end
end
