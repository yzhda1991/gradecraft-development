class ChangePointsNomenclature < ActiveRecord::Migration
  def change
    rename_column :earned_badges, :score, :points
    rename_column :grade_scheme_elements, :low_range, :low_points
    rename_column :grade_scheme_elements, :high_range, :high_points
    rename_column :grades, :raw_score, :raw_points
    rename_column :grades, :final_score, :final_points
    rename_column :grades, :point_total, :full_points
    rename_column :challenges, :point_total, :full_points
    rename_column :courses, :point_total, :full_points
    rename_column :assignments, :point_total, :full_points
    rename_column :badges, :point_total, :full_points
    rename_column :challenge_grades, :final_score, :final_points
    rename_column :assignment_score_levels, :value, :points
    rename_column :challenge_score_levels, :value, :points
  end
end
