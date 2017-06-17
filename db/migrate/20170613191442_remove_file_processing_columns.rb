class RemoveFileProcessingColumns < ActiveRecord::Migration[5.0]
  def change
    remove_column :assignment_files, :file_processing, :boolean
    remove_column :badge_files, :file_processing, :boolean
    remove_column :challenge_files, :file_processing, :boolean
    remove_column :file_uploads, :file_processing, :boolean
    remove_column :submission_files, :file_processing, :boolean
  end
end
