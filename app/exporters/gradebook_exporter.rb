class GradebookExporter

  # gradebook spreadsheet export for course
  def gradebook(course)
    CSV.generate do |csv|
      csv << gradebook_columns(course)
      course.students.order_by_name.each do |student|
        csv << student_data_for(student, course)
      end
    end
  end

  private

  def base_student_columns
    ["First Name", "Last Name", "Email", "Username", "Team", "Earned Badge Score"]
  end

  def assignment_name_columns(course)
    assignment_names = []
    course.assignment_types.ordered.each do |type|
      type.assignments.ordered.each do |assignment|
        assignment_names << assignment.name
      end
    end
    assignment_names
  end

  def gradebook_columns(course)
    base_student_columns + assignment_name_columns(course)
  end

  def base_student_methods
    [:first_name, :last_name, :email, :username]
  end

  def student_data_for(student, course)
    # add the base column names
    student_data = base_student_methods.inject([]) do |memo, method|
      memo << student.send(method)
    end

    student_data << student.team_for_course(course).try(:name)

    # If a course doesn't have badges, this will return 0
    student_data << student.earned_badge_score_for_course(course)

    # add the grades for the necessary assignments
    course.assignments.order(:assignment_type_id, :id).inject(student_data) do |memo, assignment|
      grade = assignment.grade_for_student(student)
      score = GradeProctor.new(grade).viewable? ? grade.final_points : ""
      memo << score
      memo
    end
  end
end
