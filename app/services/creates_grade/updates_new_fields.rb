# Remove after grading release refactor is complete

# Until we are using grade.complete and grade.student_visible
# we need to check every update to grade.status and
# update these fields accordingly

module Services
  module Actions
    class UpdatesNewFields
      extend LightService::Action

      # expects a grade with a current status
      expects :grade

      executed do |context|
        grade = context[:grade]

        if grade.status == "In Progress"
          grade.update(complete: false, student_visible: false)
        elsif grade.status == "Graded"
          if grade.assignment.release_necessary
            grade.update(complete: true, student_visible: false)
          else
            grade.update(complete: true, student_visible: true)
          end
        elsif grade.status == "Released"
          grade.update(complete: true, student_visible: true)
        end
      end
    end
  end
end
