class RenameWeightTermsOnCourse < ActiveRecord::Migration
  def change
    rename_column :courses, :assignment_weight_close_at, :weights_close_at
    rename_column :courses, :default_assignment_weight, :default_weight
    rename_column :courses, :total_assignment_weight, :total_weights
    rename_column :courses, :max_assignment_weight, :max_weights_per_assignment_type
    remove_column :courses, :assignment_weight_type
  end
end
