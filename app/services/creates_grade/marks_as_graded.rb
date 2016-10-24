module Services
  module Actions
    class MarksAsGraded
      extend LightService::Action
      
      expects :grade

      executed do |context|
        context[:grade].instructor_modified = true
        context[:grade].graded_at = DateTime.now
      end
    end
  end
end
