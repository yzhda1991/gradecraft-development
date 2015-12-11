class ChangeDefaultCourseIdToCurrentCourseIdOnUsers < ActiveRecord::Migration
  def change
    rename_column :users, :default_course_id, :current_course_id
  end
end
