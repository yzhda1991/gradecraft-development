class AddCourseIdToUnlockConditions < ActiveRecord::Migration[5.0]
  def change
    add_column :unlock_conditions, :course_id, :integer
    add_index :unlock_conditions, :course_id
  end
end
