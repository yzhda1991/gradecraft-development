class AddIndexToCriterionGrades < ActiveRecord::Migration
  def change
    add_index :criterion_grades, [:criterion_id, :student_id], unique: true, using: :btree
    remove_column :criterion_grades, :criterion_name
    remove_column :criterion_grades, :criterion_description
    remove_column :criterion_grades, :max_points
    remove_column :criterion_grades, :order
    remove_column :criterion_grades, :level_name
    remove_column :criterion_grades, :level_description
    remove_column :criterion_grades, :submission_id
  end
end

