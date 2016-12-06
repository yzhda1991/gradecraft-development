class AddHasMaxValueToAssignmentType < ActiveRecord::Migration[5.0]
  def change
    add_column :assignment_types, :has_max_points, :boolean, default: false, null: false
  end
end
