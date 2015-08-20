class RemoveStudentLoggedFieldsFromAssignmentTypes < ActiveRecord::Migration
  def change
    # Move the data from assignment types to assignments
    AssignmentType.includes(:assignments).find_each do |type|
      type.assignments.each do |assignment|
        assignment.student_logged_button_text = type.student_logged_button_text
        assignment.student_logged_revert_button_text =
          type.student_logged_revert_button_text
        assignment.save validate: false
      end
    end

    remove_column :assignment_types, :student_logged_button_text
    remove_column :assignment_types, :student_logged_revert_button_text
  end
end
