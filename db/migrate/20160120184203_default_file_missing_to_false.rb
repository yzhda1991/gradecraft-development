class DefaultFileMissingToFalse < ActiveRecord::Migration
  def up
    change_column_default(:submission_files, :file_missing, false)
  end

  def down
    change_column_default(:submission_files, :file_missing, nil)
  end
end
