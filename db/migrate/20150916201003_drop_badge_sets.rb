class DropBadgeSets < ActiveRecord::Migration
  def change
    drop_table :badge_sets
    drop_table :badge_sets_courses
  end
end
