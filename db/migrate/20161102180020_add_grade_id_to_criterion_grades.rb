class AddGradeIdToCriterionGrades < ActiveRecord::Migration[5.0]
  def change
    add_column :criterion_grades, :grade_id, :integer
  end
end
