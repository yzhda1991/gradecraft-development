class CleanupAssignmentTypeTable < ActiveRecord::Migration
  def change
    remove_column :assignment_types, :points_predictor_display
    remove_column :assignment_types, :levels
    remove_column :assignment_types, :resubmission
    remove_column :assignment_types, :percentage_course
    remove_column :assignment_types, :universal_point_value
    remove_column :assignment_types, :minimum_score
    remove_column :assignment_types, :step_value
    remove_column :assignment_types, :grade_scheme_id
    remove_column :assignment_types, :due_date_present
    remove_column :assignment_types, :order_placement
    remove_column :assignment_types, :mass_grade
    remove_column :assignment_types, :mass_grade_type
    remove_column :assignment_types, :notify_released 
    remove_column :assignment_types, :include_in_timeline
    remove_column :assignment_types, :include_in_predictor
    remove_column :assignment_types, :include_in_to_do
    remove_column :assignment_types, :is_attendance
    remove_column :assignment_types, :has_winners
    remove_column :assignment_types, :num_winner_levels
    rename_column :assignment_types, :predictor_description, :description
    rename_column :assignment_types, :max_value, :max_points
  end
end
