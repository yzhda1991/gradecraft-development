class MoveWeightsToAssignmentType < ActiveRecord::Migration
  def change
    #rename_index :assignment_weights, "index_assignment_weights_on_student_id_and_assignment_type_id", "index_weights_on_student_and_assignment_type"

    rename_table :assignment_weights, :assignment_type_weights
    remove_column :assignment_type_weights, :assignment_id
    remove_column :assignment_type_weights, :point_total
  end
end
