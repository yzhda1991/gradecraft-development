class ExcludeGradeFromCourseScore < ActiveRecord::Migration
  def change
    add_column :grades, :excluded_from_course_score, :boolean, default: false
    add_column :grades, :excluded_at, :datetime
    add_column :grades, :excluded_by_id, :integer
  end
end
