class CreateLearningObjectiveCategory < ActiveRecord::Migration[5.0]
  def change
    create_table :learning_objective_categories do |t|
      t.integer :course_id, null: false
      t.string :name, null: false
    end

    add_foreign_key :learning_objective_categories, :courses
  end
end
