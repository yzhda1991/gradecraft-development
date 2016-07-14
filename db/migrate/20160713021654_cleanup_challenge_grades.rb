class CleanupChallengeGrades < ActiveRecord::Migration
  def change
    remove_column :challenge_grades, :feedback
    change_column :challenge_grades, :challenge_id, :integer, null: false
    change_column :challenge_grades, :team_id, :integer, null: false
    rename_column :challenge_grades, :text_feedback, :feedback
  end
end
