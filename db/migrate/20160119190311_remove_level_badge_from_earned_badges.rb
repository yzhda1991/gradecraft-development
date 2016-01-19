class RemoveLevelBadgeFromEarnedBadges < ActiveRecord::Migration
  def change
    remove_column :earned_badges, :level_badge_id
  end
end
