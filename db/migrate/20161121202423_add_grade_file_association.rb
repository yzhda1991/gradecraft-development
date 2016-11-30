class AddGradeFileAssociation < ActiveRecord::Migration[5.0]
  def change
    rename_table :grade_files, :file_attachments
    create_table :grade_files do |t|
      t.integer :grade_id, null: false
      t.integer :grade_file_id, null: false
    end
  end
end
