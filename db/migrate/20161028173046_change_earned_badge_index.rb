class ChangeEarnedBadgeIndex < ActiveRecord::Migration[5.0]
  def change
    remove_index :earned_badges, [:grade_id, :badge_id]
    add_index :earned_badges, [:grade_id, :badge_id]
  end
end
