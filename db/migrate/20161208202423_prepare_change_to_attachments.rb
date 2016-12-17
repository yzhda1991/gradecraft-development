class PrepareChangeToAttachments < ActiveRecord::Migration[5.0]
  def change
    rename_table :grade_files, :file_uploads
    create_table :attachments do |t|
      t.integer :grade_id, null: false
      t.integer :file_upload_id, null: false
    end
  end
end
