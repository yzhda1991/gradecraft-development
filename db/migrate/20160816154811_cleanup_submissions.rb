class CleanupSubmissions < ActiveRecord::Migration
  def change
    change_column :submissions, :assignment_id, :integer, null: false
    change_column :submissions, :created_at, :datetime, null: false
    change_column :submissions, :updated_at, :datetime, null: false
    change_column :submissions, :course_id, :integer, null: false
    
    remove_column :submissions, :feedback
    remove_column :submissions, :comment
    remove_column :submissions, :creator_id
    remove_column :submissions, :released_at
    remove_column :submissions, :task_id
    remove_column :submissions, :assignment_type_id
    remove_column :submissions, :assignment_type
  end
end
