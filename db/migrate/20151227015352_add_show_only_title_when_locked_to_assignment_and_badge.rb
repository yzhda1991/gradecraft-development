class AddShowOnlyTitleWhenLockedToAssignmentAndBadge < ActiveRecord::Migration
  def change
    add_column :assignments, :show_name_when_locked, :boolean, default: true
    add_column :assignments, :show_points_when_locked, :boolean, default: true
    add_column :assignments, :show_description_when_locked, :boolean, default: true
    add_column :badges, :show_name_when_locked, :boolean, default: true
    add_column :badges, :show_points_when_locked, :boolean, default: true
    add_column :badges, :show_description_when_locked, :boolean, default: true
  end
end
