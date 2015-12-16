class CreateAssignmentExports < ActiveRecord::Migration
  def change
    create_table :assignment_exports do |t|
      t.integer :assignment_id
      t.integer :course_id
      t.integer :professor_id
      t.integer :student_ids, array: true, default: [], null: false
      t.integer :team_id

      t.text :export_filename
      t.text :s3_object_key
      t.text :s3_symmetric_key

      t.text :errors, array:true, default: [], null: false
      t.hstore :submissions_snapshot, default: {}, null: false

      t.timestamps null: false
    end
  end
end
