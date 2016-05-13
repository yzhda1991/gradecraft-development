class AssignmentTypeUpdates < ActiveRecord::Migration
  def change
    change_column :assignment_types, :name, :string, null: false
    change_column :assignment_types, :max_points, :integer, default: 0, null: false
    change_column :assignment_types, :created_at, :datetime, null: false
    change_column :assignment_types, :updated_at, :datetime, null: false
    change_column :assignment_types, :course_id, :integer, null: false
    change_column :assignment_types, :student_weightable, :boolean, default: false, null: false
    change_column :assignment_types, :position, :integer, null: false
  end
end
