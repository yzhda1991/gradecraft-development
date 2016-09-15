class AddNotNullsToPredictions < ActiveRecord::Migration
  def change
    change_column :predicted_earned_badges, :badge_id, :integer, null: false
    change_column :predicted_earned_badges, :student_id, :integer, null: false
    change_column :predicted_earned_badges, :predicted_times_earned, :integer, null: false, default: 0
    change_column :predicted_earned_badges, :created_at, :datetime, null: false
    change_column :predicted_earned_badges, :updated_at, :datetime, null: false

    change_column :predicted_earned_challenges, :challenge_id, :integer, null: false
    change_column :predicted_earned_challenges, :student_id, :integer, null: false
    change_column :predicted_earned_challenges, :predicted_points, :integer, null: false, default: 0
    change_column :predicted_earned_challenges, :created_at, :datetime, null: false
    change_column :predicted_earned_challenges, :updated_at, :datetime, null: false

    change_column :predicted_earned_grades, :assignment_id, :integer, null: false
    change_column :predicted_earned_grades, :student_id, :integer, null: false
    change_column :predicted_earned_grades, :predicted_points, :integer, null: false, default: 0
    change_column :predicted_earned_grades, :created_at, :datetime, null: false
    change_column :predicted_earned_grades, :updated_at, :datetime, null: false
  end
end
