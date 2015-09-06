class ChangeMediaFileToMediaOnCourses < ActiveRecord::Migration
  def change
    rename_column :courses, :media_file, :media
  end
end
