class AddReleaseFieldsToChallengeGrade < ActiveRecord::Migration[5.0]
  def change
    add_column :challenge_grades, :complete, :boolean, null: false, default: false
    add_column :challenge_grades, :student_visible, :boolean, null: false, default: false
  end
end
