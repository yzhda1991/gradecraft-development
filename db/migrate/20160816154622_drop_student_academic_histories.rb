class DropStudentAcademicHistories < ActiveRecord::Migration
  def change
    drop_table :student_academic_histories
  end
end
