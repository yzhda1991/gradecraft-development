class AddNotNullToGroups < ActiveRecord::Migration
  def change
    change_column :group_memberships, :group_id, :integer, null: false
    change_column :group_memberships, :student_id, :integer, null: false
    change_column :group_memberships, :created_at, :datetime, null: false
    change_column :group_memberships, :updated_at, :datetime, null: false
    change_column :group_memberships, :course_id, :integer, null: false
    remove_column :group_memberships, :group_type
    
    change_column :groups, :name, :string, null: false
    change_column :groups, :created_at, :datetime, null: false
    change_column :groups, :updated_at, :datetime, null: false
    change_column :groups, :course_id, :integer, null: false
  end
end
