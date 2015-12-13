class MultipliedGradebookExporter

  #gradebook spreadsheet export for course with multipliers
  def multiplied_gradebook(course_id)
    course = fetch_course(course_id)
    CSV.generate do |csv|
      csv << gradebook_columns(course)
      course.students.each do |student|
        csv << base_column_data_for(student, course) + multiplied_grade_data_for(student, course)
      end
    end
  end

  private

  def fetch_course(course_id)
    Course.find(course_id)
  end

  def base_assignment_columns
    ["First Name", "Last Name", "Email", "Username", "Team"]
  end

  def assignments
    @assignments ||= @course.assignments.sort_by(&:created_at)
  end

  def gradebook_columns(course)
    base_assignment_columns + assignment_name_columns(course)
  end

  def assignment_name_columns(course)
    course.assignments.collect do |assignment|
      [ assignment.name, assignment.name ]
    end.flatten
  end

  def multiplied_grade_data_for(student, course)
    # add the grades for the necessary assignments, todo: improve the performance here
    course.assignments.inject(student_data) do |memo, assignment|
      grade = assignment.grade_for_student(student)
      if grade and grade.is_student_visible?
        memo << grade.try(:score)
      end
      memo
    end
  end
end
