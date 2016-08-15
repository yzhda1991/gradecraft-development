class AddNotNullToFlaggedState < ActiveRecord::Migration
  def change
    change_column :flagged_users, :course_id, :integer, null: false
    change_column :flagged_users, :flagger_id, :integer, null: false
    change_column :flagged_users, :flagged_id, :integer, null: false
    change_column :flagged_users, :created_at, :datetime, null: false
    change_column :flagged_users, :updated_at, :datetime, null: false
  end
end
