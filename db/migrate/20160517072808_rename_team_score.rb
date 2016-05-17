class RenameTeamScore < ActiveRecord::Migration
  def change
    rename_column :teams, :score, :challenge_grade_score
    add_column :teams, :average_score, :integer, default: 0, null: false
  end
end
