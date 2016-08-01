class RenameProfessorToOwner < ActiveRecord::Migration
  def change
    rename_column :course_analytics_exports, :professor_id, :owner_id
  end
end
