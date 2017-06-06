class AddReleaseFieldsToGrade < ActiveRecord::Migration[5.0]
  def change
    add_column :grades, :complete, :boolean, null: false, default: false
    add_column :grades, :student_visible, :boolean, null: false, default: false
  end
end
