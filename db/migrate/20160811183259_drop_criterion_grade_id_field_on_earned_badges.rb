class DropCriterionGradeIdFieldOnEarnedBadges < ActiveRecord::Migration
  def change
    remove_column :earned_badges, :criterion_grade_id
  end
end
