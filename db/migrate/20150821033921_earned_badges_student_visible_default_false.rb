class EarnedBadgesStudentVisibleDefaultFalse < ActiveRecord::Migration
  def change
    change_column_default(:earned_badges, :student_visible, false)
  end
end
