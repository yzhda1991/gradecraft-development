class AddCourseIdToRubrics < ActiveRecord::Migration[5.0]
  def change
    add_column :rubrics, :course_id, :integer
  end
end
