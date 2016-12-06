class RemoveRequirementFromAtMaxPoints < ActiveRecord::Migration[5.0]
  def change
    change_column_null :assignment_types, :max_points, true
  end
end
