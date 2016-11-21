class AddGradeFileAssociation < ActiveRecord::Migration[5.0]
  def change
    create_table :grade_file_associations do |t|
      t.integer :grade_id, null: false
      t.integer :grade_file_id, null: false
    end
  end
end
