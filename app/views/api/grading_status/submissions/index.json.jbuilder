json.data @submissions do |submission|
  assignment = submission.assignment
  if assignment.is_individual?
    student = submission.student
    grade = assignment.grade_for_student student
    team = student.team_for_course current_course
  end

  json.type "submissions"
  json.id submission.id.to_s

  json.attributes do
    json.id submission.id.to_s

    if assignment.is_individual?
      submission.student.tap do |student|
        json.student_name student.name
        json.student_path student_path student
      end

      if grade.present?
        json.grade_path grade_path grade
        json.edit_grade_link edit_grade_link_to(grade, class: "button")
      end

      if team.present?
        json.team_name team.name
        json.team_path team_path team
      end
    else
      json.group_grade_path grade_assignment_group_path assignment, submission.group
    end

    submission.submitted_at.in_time_zone(current_user.time_zone).tap do |submitted_at|
      json.submitted_at submitted_at
      json.formatted_submitted_at l submitted_at
    end

    json.assignment_name submission.assignment.name
    json.individual_assignment submission.assignment.is_individual?
    json.assignment_path assignment_path assignment

    json.assignment_student_grade_path assignment_student_grade_path(assignment, student) \
      if assignment.is_individual? && grade.nil?

    json.submission_path assignment_submission_path assignment,
      submission, group_id: submission.group.try(:id)
  end

  json.relationships do
    if assignment.is_individual?
      json.grade do
        json.data do
          assignment.grade_for_student(student).try(:tap) do |grade|
            json.type "grades"
            json.id grade.id.to_s
          end if assignment.is_individual?
        end
      end

      json.student_team do
        json.data do
          json.type "teams"
          json.id team.id.to_s
        end
      end
    end

    json.assignment do
      json.data do
        json.type "assignments"
        json.id assignment.id.to_s
      end
    end

    # TODO: group-graded assignments currently don't show grading buttons?
  end
end

json.meta do
  json.term_for_assignment term_for :assignment
end
