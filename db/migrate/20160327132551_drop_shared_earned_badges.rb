class DropSharedEarnedBadges < ActiveRecord::Migration
  def change
    drop_table :shared_earned_badges
  end
end
