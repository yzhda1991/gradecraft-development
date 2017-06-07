class AddActiveToCourseMemberships < ActiveRecord::Migration[5.0]
  def change
    add_column :course_memberships, :active, :boolean, default: true, null: false
  end
end
