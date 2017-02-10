module Services
  module Actions
    class SquishGradeHistory
      extend LightService::Action

      expects :grade

      executed do |context|
        grade = context[:grade]
        grade.squish_history!
      end
    end
  end
end
