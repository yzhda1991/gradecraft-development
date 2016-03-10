class AddPointsAdjustmentToGrades < ActiveRecord::Migration
  def change
    add_column :grades, :adjustment_points, :integer, default: 0, null: false
    add_column :grades, :adjustment_points_feedback, :text
  end
end
