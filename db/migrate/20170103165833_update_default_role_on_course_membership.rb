class UpdateDefaultRoleOnCourseMembership < ActiveRecord::Migration[5.0]
  def change
    change_column_default(:course_memberships, :role, "observer")
  end
end
