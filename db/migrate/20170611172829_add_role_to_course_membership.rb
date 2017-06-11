class AddRoleToCourseMembership < ActiveRecord::Migration[5.0]
  def change
    add_column :course_memberships, :team_role, :string
  end
end
