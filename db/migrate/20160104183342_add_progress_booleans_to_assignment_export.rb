class AddProgressBooleansToAssignmentExport < ActiveRecord::Migration
  def change
    add_column :assignment_exports, :generate_export_csv, :boolean
    add_column :assignment_exports, :export_csv_successful, :boolean
    add_column :assignment_exports, :create_student_directories, :boolean
    add_column :assignment_exports, :student_directories_created_successfully, :boolean
    add_column :assignment_exports, :create_submission_text_files, :boolean
    add_column :assignment_exports, :create_submission_binary_files, :boolean
    add_column :assignment_exports, :generate_error_log, :boolean
    add_column :assignment_exports, :archive_exported_files, :boolean
    add_column :assignment_exports, :upload_archive_to_s3, :boolean
    add_column :assignment_exports, :check_s3_upload_success, :boolean
  end
end
