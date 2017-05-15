class DropNotNullFromGradeSchemeElements < ActiveRecord::Migration[5.0]
  def change
    change_column :grade_scheme_elements, :lowest_points, :integer
  end
end
