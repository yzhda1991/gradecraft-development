class AddCourseToAcademicHistory < ActiveRecord::Migration
  def change
    add_column :student_academic_histories, :course_id, :integer 
  end
end
