class AddNotNullToEvents < ActiveRecord::Migration
  def change
    change_column :events, :name, :string, null: false
    change_column :events, :due_at, :datetime, null: false
    change_column :events, :updated_at, :datetime, null: false
    change_column :events, :created_at, :datetime, null: false
    change_column :events, :course_id, :integer, null: false
  end
end
