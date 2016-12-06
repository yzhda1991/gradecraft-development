class RemoveDefaultFromMaxPoints < ActiveRecord::Migration[5.0]
  def change
    change_column :assignment_types, :max_points, :integer, default: nil
  end
end
