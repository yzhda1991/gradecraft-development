class CourseGradeExporter

  # final grades: total score + grade earned in course
  def final_grades_for_course(course)
    CSV.generate do |csv|
      csv.add_row baseline_headers
      course.students.order_by_name.each do |student|
        csv.add_row student_data(student, course)
      end
    end
  end

  private

  def baseline_headers
    ["First Name", "Last Name", "Email", "Username", "Score", "Grade", "Level",
      "Earned Badge #", "GradeCraft ID", "GradeCraft Account Created", "Last Logged In At", "Auditing" ]
  end

  def student_data(student, course)
    [student.first_name,
      student.last_name,
      student.email,
      student.username,
      student.score_for_course(course),
      student.grade_letter_for_course(course),
      student.grade_level_for_course(course),
      student.earned_badges_for_course(course).count,
      student.id,
      student.created_at,
      student.last_course_login(course),
      student.course_memberships.where(course: course).first.auditing ? "Yes" : "No"]
  end
end
