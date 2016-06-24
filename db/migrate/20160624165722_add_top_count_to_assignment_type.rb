class AddTopCountToAssignmentType < ActiveRecord::Migration
  def change
    add_column :assignment_types, :top_grades_counted, :integer, default: 0, null: false
  end
end
