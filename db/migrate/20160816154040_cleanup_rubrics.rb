class CleanupRubrics < ActiveRecord::Migration
  def change
    change_column :rubrics, :assignment_id, :integer, null: false
    change_column :rubrics, :created_at, :datetime, null: false
    change_column :rubrics, :updated_at, :datetime, null: false
  end
end
