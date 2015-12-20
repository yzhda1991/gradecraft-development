class ChangeAssignmentExportAttributes < ActiveRecord::Migration
  def change
    rename_column :assignment_exports, :s3_symmetric_key, :s3_bucket
  end
end
