class DropCourseBadgeSets < ActiveRecord::Migration
  def change
    drop_table :course_badge_sets
    drop_table :course_categories
  end
end
