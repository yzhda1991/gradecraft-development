class DropExtraAssignmentFields < ActiveRecord::Migration
  def change
    remove_column :assignments, :close_time
    remove_column :assignments, :open_time
    remove_column :assignments, :level
    remove_column :assignments, :present
    remove_column :assignments, :grade_scheme_id
    remove_column :assignments, :student_logged_button_text
    remove_column :assignments, :student_logged_revert_button_text
  end
end
