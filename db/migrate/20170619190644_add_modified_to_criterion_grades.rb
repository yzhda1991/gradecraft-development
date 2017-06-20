class AddModifiedToCriterionGrades < ActiveRecord::Migration[5.0]
  def change
    add_column :challenge_grades, :instructor_modified, :boolean, null: false, default: false
  end
end
