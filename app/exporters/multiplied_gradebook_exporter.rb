class MultipliedGradebookExporter

  #gradebook spreadsheet export for course with multipliers
  def multiplied_gradebook(course_id)
    course = fetch_course(course_id)
    CSV.generate do |csv|
      csv << gradebook_columns(course)
      course.students.each do |student|
        csv << student_data_for(student, course)
      end
    end
  end

  private

  def fetch_course(course_id)
    Course.find(course_id)
  end

  def base_student_columns
    ["First Name", "Last Name", "Email", "Username", "Team"]
  end

  def gradebook_columns(course)
    base_student_columns + assignment_name_columns(course)
  end

  def assignment_name_columns(course)
    course.assignments.collect do |assignment|
      [ assignment.name, assignment.name ]
    end.flatten
  end

  def base_student_methods
     [:first_name, :last_name, :email, :username]
  end

  def student_data_for(student, course)
    # add the base column names
    student_data = base_student_methods.inject([]) do |memo, method|
      memo << student.send(method)
    end
    # todo: we need to pre-fetch the course teams for this
    student_data << student.team_for_course(course).try(:name)

    # add the grades for the necessary assignments, todo: improve the performance here
    course.assignments.inject(student_data) do |memo, assignment|
      grade = assignment.grade_for_student(student)
      if grade and grade.is_student_visible?
        memo << grade.try(:raw_score)
        memo << grade.try(:score)
      else
        memo << ""
        memo << ""
      end
      memo
    end
  end
end
