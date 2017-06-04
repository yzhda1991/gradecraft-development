class AddCourseCreation < ActiveRecord::Migration[5.0]
  def change
    create_table :course_creations do |t|
      t.integer :course_id
      t.boolean :settings_done, default: false, null: false
      t.boolean :attendance_done, default: false, null: false
      t.boolean :assignments_done, default: false, null: false
      t.boolean :calendar_done, default: false, null: false
      t.boolean :instructors_done, default: false, null: false
      t.boolean :roster_done, default: false, null: false
      t.boolean :badges_done, default: false, null: false
      t.boolean :teams_done, default: false, null: false
      t.timestamps
    end
  end
end
