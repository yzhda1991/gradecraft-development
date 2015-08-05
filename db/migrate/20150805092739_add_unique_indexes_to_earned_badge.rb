class AddUniqueIndexesToEarnedBadge < ActiveRecord::Migration
  def change
    add_index :earned_badges, [:grade_id, :badge_id], unique: true
  end
end
