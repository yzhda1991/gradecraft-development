class DropNullConstraint < ActiveRecord::Migration[5.0]
  def change
    change_column_null :grade_scheme_elements, :lowest_points, true
  end
end
