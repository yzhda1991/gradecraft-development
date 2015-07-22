class AddPredictedEarnedBadges < ActiveRecord::Migration
  def change
    create_table :predicted_earned_badges do |t|
      t.integer :badge_id
      t.integer :student_id
      t.integer :times_earned, default: 0
      t.timestamps
    end
  end
end
