class AddTimestampsToAssignmentExports < ActiveRecord::Migration
  def change
    add_column :assignment_exports, :last_export_started_at, :datetime
    add_column :assignment_exports, :last_export_completed_at, :datetime
  end
end
