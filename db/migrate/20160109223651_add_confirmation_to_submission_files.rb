class AddConfirmationToSubmissionFiles < ActiveRecord::Migration
  def change
    add_column :submission_files, :last_confirmed_at, :datetime
    add_column :submission_files, :file_missing, :boolean
  end
end
