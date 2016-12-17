class AddAdjustmentPointsFeedback < ActiveRecord::Migration[5.0]
  def change
    add_column :challenge_grades, :adjustment_points_feedback, :text
  end
end
