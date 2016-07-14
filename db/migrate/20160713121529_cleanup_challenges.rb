class CleanupChallenges < ActiveRecord::Migration
  def change
    remove_column :challenges, :points_predictor_display
    change_column :challenges, :name, :string, null: false
    change_column :challenges, :course_id, :integer, null: false
    change_column :challenges, :visible, :boolean, default: true, null: false
    change_column :challenges, :accepts_submissions, :boolean, default: true, null: false
    change_column :challenges, :release_necessary, :boolean, default: false, null: false
    change_column :challenges, :created_at, :datetime, null: false
    change_column :challenges, :updated_at, :datetime, null: false
  end
end
