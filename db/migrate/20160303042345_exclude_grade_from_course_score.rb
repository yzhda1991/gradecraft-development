class ExcludeGradeFromCourseScore < ActiveRecord::Migration
  def change
    add_column :grades, :excluded_from_course_score, :boolean, default: false
    add_column :grades, :excluded_date, :datetime
    add_column :grades, :excluded_by, :integer
  end
end
