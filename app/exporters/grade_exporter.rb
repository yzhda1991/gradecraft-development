class GradeExporter
  # For exports and csv import sample; return "0" or "1" vs "Fail", "Pass"
  # if pass_fail_statuses_as_int is true
  def export_grades(assignment, students, pass_fail_statuses_as_int=false, options={})
    CSV.generate(options) do |csv|
      csv << headers
      students.each do |student|
        grade = student.grade_for_assignment(assignment)
        csv << [student.first_name, student.last_name,
                student.email,
                score_for_assignment_type(assignment, grade, pass_fail_statuses_as_int) || "",
                grade.feedback || ""]
      end
    end
  end

  # By default, return pass/fail status as score ("Pass" or "Fail")
  # if assignment is pass/fail type; for exports
  def export_group_grades(assignment, groups, options={})
    CSV.generate(options) do |csv|
      csv << group_headers
      groups.each do |group|
        grade = group.grade_for_assignment(assignment)
        csv << [group.name,
                score_for_assignment_type(assignment, grade, false) || "",
                grade.feedback || ""]
      end
    end
  end

  # By default, return pass/fail status as score ("Pass" or "Fail")
  # if assignment is pass/fail type, for exports
  def export_grades_with_detail(assignment, students, options={})
    CSV.generate(options) do |csv|
      csv << headers + detail_headers
      students.each do |student|
        grade = student.grade_for_assignment(assignment)
        grade = Grade.new if !(grade.instructor_modified? || grade.graded_or_released?)
        submission = student.submission_for_assignment(assignment)
        csv << [student.first_name, student.last_name,
                student.email,
                score_for_assignment_type(assignment, grade, false) || "",
                grade.feedback || "",
                grade.raw_points || "",
                submission.try(:text_comment) || "",
                grade.graded_at || ""]
      end
    end
  end

  def group_headers
    ["Group Name", "Score", "Feedback"].freeze
  end

  private

  def headers
    ["First Name", "Last Name", "Email", "Score", "Feedback"].freeze
  end

  def detail_headers
    ["Raw Score", "Statement", "Last Updated"].freeze
  end

  def score_for_assignment_type(assignment, grade, pass_fail_statuses_as_int)
    if assignment.pass_fail?
      return grade.pass_fail_status unless pass_fail_statuses_as_int
      pass_fail_status_as_int(grade.pass_fail_status)
    else
      grade.score
    end
  end

  def pass_fail_status_as_int(status)
    case status
    when "Pass" then 1
    when "Fail" then 0
    end
  end
end
