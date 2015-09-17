class DropElements < ActiveRecord::Migration
  def change
    drop_table :elements
    drop_table :course_grade_scheme_elements
    drop_table :course_grade_schemes
  end
end
