class RenameAssignmentExport < ActiveRecord::Migration
  def change
    rename_table :assignment_exports, :submissions_exports
  end
end
