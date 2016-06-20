class CleanupAssignmentTable < ActiveRecord::Migration
  def change
    remove_column :assignments, :icon
    remove_column :assignments, :can_earn_multiple_times
    remove_column :assignments, :category_id
    remove_column :assignments, :role_necessary_for_release
    remove_column :assignments, :points_predictor_display
  end
end
