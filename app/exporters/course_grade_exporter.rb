class CourseGradeExporter

  #final grades: total score + grade earned in course
  def final_grades_for_course(course, students)
    CSV.generate do |csv|
      csv.add_row baseline_headers
      if students.present?
        students.each do |student|
          csv << [student.first_name, student.last_name, student.email, student.username, student.cached_score_for_course(course), student.earned_badges.count, student.id ]
        end
      end
    end
  end

  private

  def baseline_headers
    ["First Name", "Last Name", "Email", "Username", "Score", "Grade", "Level", "Earned Badge #", "GradeCraft ID" ]
  end

end
