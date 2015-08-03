class AddPredictedEarnedChallenges < ActiveRecord::Migration
  def change
    create_table :predicted_earned_challenges do |t|
      t.integer :challenge_id
      t.integer :student_id
      t.integer :points_earned, default: 0
      t.timestamps
    end
  end
end
