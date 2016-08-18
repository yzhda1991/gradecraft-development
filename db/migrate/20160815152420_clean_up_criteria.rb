class CleanUpCriteria < ActiveRecord::Migration
  def change
    change_column :criteria, :name, :string, null: false
    change_column :criteria, :rubric_id, :integer, null: false
    change_column :criteria, :created_at, :datetime, null: false
    change_column :criteria, :updated_at, :datetime, null: false
    change_column :criteria, :order, :integer, null: false
    
    
    change_column :criterion_grades, :created_at, :datetime, null: false
    change_column :criterion_grades, :updated_at, :datetime, null: false
    change_column :criterion_grades, :criterion_id, :integer, null: false
    change_column :criterion_grades, :assignment_id, :integer, null: false
    change_column :criterion_grades, :student_id, :integer, null: false
  end
end
