class CreateAssignmentExports < ActiveRecord::Migration
  def change
    create_table :assignment_exports do |t|
      t.integer :assignment_id
      t.integer :course_id
      t.integer :professor_id
      t.integer :student_ids, array: true, default: []
      t.integer :team_id

      t.text :errors, array:true, default: []
      t.hstore :submissions_snapshot, default: {}

      t.timestamps null: false
    end
  end
end
