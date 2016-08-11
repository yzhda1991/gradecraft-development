class RemoveUnnecessaryFieldsFromBadges < ActiveRecord::Migration
  def change
    change_column :earned_badges, :badge_id, :integer, null: false
    change_column :earned_badges, :course_id, :integer, null: false
    change_column :earned_badges, :student_id, :integer, null: false
    change_column :earned_badges, :points, :integer, null: false, default: 0
    change_column :earned_badges, :created_at, :datetime, null: false
    change_column :earned_badges, :updated_at, :datetime, null: false
    change_column :earned_badges, :student_visible, :boolean, null: false, default: false

    remove_column :earned_badges, :task_id
    remove_column :earned_badges, :group_id
    remove_column :earned_badges, :group_type
    remove_column :earned_badges, :shared
  end
end
