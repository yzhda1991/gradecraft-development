class RemoveStepBooleansFromSubmissionsExport < ActiveRecord::Migration
  def up
    remove_column :submissions_exports, :generate_export_csv
    remove_column :submissions_exports, :confirm_export_csv_integrity
    remove_column :submissions_exports, :create_student_directories
    remove_column :submissions_exports, :student_directories_created_successfully
    remove_column :submissions_exports, :create_submission_text_files
    remove_column :submissions_exports, :create_submission_binary_files
    remove_column :submissions_exports, :write_note_for_missing_binary_files
    remove_column :submissions_exports, :remove_empty_student_directories
    remove_column :submissions_exports, :generate_error_log
    remove_column :submissions_exports, :archive_exported_files
    remove_column :submissions_exports, :upload_archive_to_s3
    remove_column :submissions_exports, :check_s3_upload_success

    add_column :submissions_exports, :last_completed_step, :string
  end

  def down
    add_column :submissions_exports, :generate_export_csv, :boolean
    add_column :submissions_exports, :confirm_export_csv_integrity, :boolean
    add_column :submissions_exports, :create_student_directories, :boolean
    add_column :submissions_exports, :student_directories_created_successfully, :boolean
    add_column :submissions_exports, :create_submission_text_files, :boolean
    add_column :submissions_exports, :create_submission_binary_files, :boolean
    add_column :submissions_exports, :write_note_for_missing_binary_files, :boolean
    add_column :submissions_exports, :remove_empty_student_directories, :boolean
    add_column :submissions_exports, :generate_error_log, :boolean
    add_column :submissions_exports, :archive_exported_files, :boolean
    add_column :submissions_exports, :upload_archive_to_s3, :boolean
    add_column :submissions_exports, :check_s3_upload_success, :boolean

    remove_column :submissions_exports, :last_completed_step
  end
end
