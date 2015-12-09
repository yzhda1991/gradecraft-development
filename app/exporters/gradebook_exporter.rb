class GradebookExporter
  
  #gradebook spreadsheet export for course
  def gradebook(course)
    CSV.generate do |csv|
      csv << standard_gradebook_columns
      course.students.each do |student|
        csv << standard_grade_data_for(student)
      end
    end
  end

  #gradebook spreadsheet export for course with multipliers
  def multiplied_gradebook(course)
    CSV.generate do |csv|
      csv << multiplied_gradebook_columns
      course.students.each do |student|
        csv << multiplied_grade_data_for(student)
      end
    end
  end

  private

  def base_assignment_columns
    ["First Name", "Last Name", "Email", "Username", "Team"]
  end

  def base_column_methods
    [:first_name, :last_name, :email, :username]
  end

  def assignments
    @assignments ||= @course.assignments.sort_by(&:created_at)
  end

  def standard_gradebook_columns
    base_assignment_columns + standard_assignment_name_columns
  end

  def multiplied_gradebook_columns
    base_assignment_columns + multiplied_assignment_name_columns
  end

  def standard_assignment_name_columns
    assignments.collect(&:name)
  end

  def multiplied_assignment_name_columns
    assignments.collect do |assignment|
      [ assignment.name, assignment.name ]
    end.flatten
  end

  def standard_grade_data_for(student)
    # add the base column elements
    student_data = base_column_methods.inject([]) do |memo, method|
      memo << student.send(method)
    end
    # todo: we need to pre-fetch the course teams for this
    student_data << student.team_for_course(@course).try(:name)

    # add the grades for the necessary assignments, todo: improve the performance here
    assignments.inject(student_data) do |memo, assignment|
      grade = assignment.grade_for_student(student)
      if grade and grade.is_student_visible?
        memo << grade.try(:raw_score)
      else
        memo << ''
      end
      memo
    end
  end

  def multiplied_grade_data_for(student)
    # add the base column elements
    student_data = base_column_methods.inject([]) do |memo, method|
      memo << student.send(method)
    end
    # todo: we need to pre-fetch the course teams for this
    student_data << student.team_for_course(@course).try(:name)

    # add the grades for the necessary assignments, todo: improve the performance here
    assignments.inject(student_data) do |memo, assignment|
      grade = assignment.grade_for_student(student)
      if grade and grade.is_student_visible?
        memo << grade.try(:score)
      end
      memo
    end
  end
end