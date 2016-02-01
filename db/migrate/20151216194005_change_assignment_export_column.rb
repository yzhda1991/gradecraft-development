class ChangeAssignmentExportColumn < ActiveRecord::Migration
  def change
    rename_column(:assignment_exports, :errors, :performer_error_log)
  end
end
