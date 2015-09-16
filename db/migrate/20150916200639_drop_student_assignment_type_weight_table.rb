class DropStudentAssignmentTypeWeightTable < ActiveRecord::Migration
  def change
    drop_table :student_assignment_type_weights
  end
end
