class CleanupScoreLevels < ActiveRecord::Migration
  def change
    change_column :challenge_score_levels, :challenge_id, :integer, null: false
    change_column :challenge_score_levels, :name, :string, null: false
    change_column :challenge_score_levels, :points, :integer, null: false
    change_column :challenge_score_levels, :created_at, :datetime, null: false
    change_column :challenge_score_levels, :updated_at, :datetime, null: false
  end
end
