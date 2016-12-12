class AddAdjustmentPointsToChallengeGrade < ActiveRecord::Migration[5.0]
  def change
    add_column :challenge_grades, :adjustment_points, :integer, default: 0, nil: false
  end
end
