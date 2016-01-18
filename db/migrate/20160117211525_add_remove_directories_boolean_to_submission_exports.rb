class AddRemoveDirectoriesBooleanToSubmissionExports < ActiveRecord::Migration
  def change
    add_column :submissions_exports, :remove_empty_student_directories, :boolean
  end
end
