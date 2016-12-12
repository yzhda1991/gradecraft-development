class ChangeScoreToRawPointsOnChallengeGrade < ActiveRecord::Migration[5.0]
  def change
    rename_column :challenge_grades, :score, :raw_points
  end
end
