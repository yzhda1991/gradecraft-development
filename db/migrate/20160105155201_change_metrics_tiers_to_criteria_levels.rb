class ChangeMetricsTiersToCriteriaLevels < ActiveRecord::Migration
  def change
    rename_table :metrics, :criteria
    rename_table :tiers, :levels
    rename_table :tier_badges, :level_badges
    rename_table :rubric_grades, :criterion_grades

    remove_column :earned_badges, :metric_id

    rename_column :criterion_grades, :tier_id, :level_id
    rename_column :criterion_grades, :tier_name, :level_name
    rename_column :criterion_grades, :tier_description, :level_description
    rename_column :level_badges, :tier_id, :level_id
    rename_column :earned_badges, :tier_id, :level_id
    rename_column :earned_badges, :tier_badge_id, :level_badge_id
    rename_column :criteria, :full_credit_tier_id, :full_credit_level_id
    rename_column :criteria, :tiers_count, :level_count

    rename_column :levels, :metric_id, :criterion_id
    rename_column :criterion_grades, :metric_id, :criterion_id
    rename_column :criterion_grades, :metric_name, :criterion_name
    rename_column :criterion_grades, :metric_description, :criterion_description

    rename_column :earned_badges, :rubric_grade_id, :criterion_grade_id
  end
end
