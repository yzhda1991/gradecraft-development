class RenameSubmissionsExportStudentIds < ActiveRecord::Migration
  def change
    rename_column :submissions_exports, :student_ids, :submitter_ids
  end
end
