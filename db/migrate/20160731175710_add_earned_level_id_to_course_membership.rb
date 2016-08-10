class AddEarnedLevelIdToCourseMembership < ActiveRecord::Migration
  def change
    add_column :course_memberships, :earned_grade_scheme_element_id, :integer
  end
end
