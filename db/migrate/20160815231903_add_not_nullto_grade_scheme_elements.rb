class AddNotNulltoGradeSchemeElements < ActiveRecord::Migration
  def change
    change_column :grade_scheme_elements, :lowest_points, :integer, null: false
    change_column :grade_scheme_elements, :course_id, :integer, null: false
  end
end
