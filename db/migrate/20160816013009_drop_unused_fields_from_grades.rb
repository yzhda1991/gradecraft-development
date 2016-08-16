class DropUnusedFieldsFromGrades < ActiveRecord::Migration
  def change
    remove_column :grades, :semis
    remove_column :grades, :complete
    remove_column :grades, :finals
    remove_column :grades, :attempted
    remove_column :grades, :substantial
    remove_column :grades, :shared
    remove_column :grades, :type
    remove_column :grades, :task_id
    remove_column :grades, :group_type
    remove_column :grades, :admin_notes
    remove_column :grades, :team_id
    remove_column :grades, :assignment_type_id
    
    change_column :grades, :assignment_id, :integer, null: false
    change_column :grades, :course_id, :integer, null: false
    change_column :grades, :student_id, :integer, null: false
    
    change_column :grades, :created_at, :datetime, null: false
    change_column :grades, :updated_at, :datetime, null: false
  end
end
