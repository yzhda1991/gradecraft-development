class AddPointsAdjustmentToGrades < ActiveRecord::Migration
  def change
    add_column :grades, :points_adjustment, :integer, default: 0, null: false
    add_column :grades, :points_adjustment_feedback, :text
  end
end
