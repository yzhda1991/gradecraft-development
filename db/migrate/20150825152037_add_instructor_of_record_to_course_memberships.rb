class AddInstructorOfRecordToCourseMemberships < ActiveRecord::Migration
  def change
    add_column :course_memberships, :instructor_of_record, :boolean, default: false
  end
end
