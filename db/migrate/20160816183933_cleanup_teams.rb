class CleanupTeams < ActiveRecord::Migration
  def change
    change_column :team_leaderships, :team_id, :integer, null: false
    change_column :team_leaderships, :leader_id, :integer, null: false
    change_column :team_leaderships, :created_at, :datetime, null: false
    change_column :team_leaderships, :updated_at, :datetime, null: false
    
    change_column :team_memberships, :team_id, :integer, null: false
    change_column :team_memberships, :student_id, :integer, null: false
    change_column :team_memberships, :created_at, :datetime, null: false
    change_column :team_memberships, :updated_at, :datetime, null: false
    
    change_column :teams, :name, :string, null: false
    change_column :teams, :course_id, :integer, null: false
    change_column :teams, :created_at, :datetime, null: false
    change_column :teams, :updated_at, :datetime, null: false 
    
    remove_column :teams, :teams_leaderboard
    change_column :teams, :in_team_leaderboard, :boolean, default: false, null: false
  end
end
