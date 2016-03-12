class CleanupCourse < ActiveRecord::Migration
  def change
    remove_column :courses, :shared_badges
    remove_column :courses, :grade_scheme_id
    remove_column :courses, :badge_set_id
    remove_column :courses, :badge_use_scope
    remove_column :courses, :badges_value
    remove_column :courses, :graph_display
    remove_column :courses, :check_final_grade
  end
end
