namespace :challenge_grades do
  desc "Update complete and student_visible fields on existing grades"
  task update_status_fields: :environment do
    ChallengeGrade.find_each(batch_size: 500) do |grade|
      instructor_modified = false
      complete = false
      student_visible = false

      if grade.status == "In Progress"
        instructor_modified = true
        complete = false
        student_visible = false
      elsif grade.status == "Graded"
        instructor_modified = true
        if grade.challenge.release_necessary
          complete = true
          student_visible = false
        else
          complete = true
          student_visible = true
        end
      elsif grade.status == "Released"
        instructor_modified = true
        complete = true
        student_visible = true
      end
      grade.update_attribute(:instructor_modified, instructor_modified) if instructor_modified
      grade.update_attribute(:complete, complete) if complete
      grade.update_attribute(:student_visible, student_visible) if student_visible
      puts "#{grade.id}: status: #{grade.status}, complete: #{grade.complete}, student_visible: #{grade.student_visible}"
    end
  end
end
