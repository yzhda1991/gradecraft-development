json.data @grades do |grade|
  json.type "grades"
  json.id grade.id.to_s

  json.attributes do
    json.id grade.id.to_s

    json.score grade.score
    json.formatted_score points grade.score
    json.feedback raw grade.feedback

    if grade.group.nil?
      json.see_grade_path grade_path(grade)
      json.edit_grade_link edit_grade_link_to(grade, class: "button")
    else
      json.edit_group_grade_link edit_group_grade_link_to(assignment, grade.group, class: "button")
    end

    grade.assignment.tap do |assignment|
      json.assignment_name assignment.name
      json.assignment_has_groups assignment.has_groups?
      json.assignment_path assignment_path(assignment)

      assignment.group.tap do |group|
        json.group_name group.try(:name)
        json.group_path group_path(group)
      end if assignment.has_groups?
    end

    grade.student.tap do |student|
      json.student_name student.name
      json.student_path student_path(student)

      student.team_for_course(current_course).tap do |team|
        json.team_name team.name
        json.team_path team_path(team)
      end
    end
  end

  # json.relationships do
  #   if assignment.is_individual?
  #     json.grade do
  #       json.data do
  #         assignment.grade_for_student(student).try(:tap) do |grade|
  #           json.type "grades"
  #           json.id grade.id.to_s
  #         end if assignment.is_individual?
  #       end
  #     end
  #
  #     json.student_team do
  #       json.data do
  #         json.type "teams"
  #         json.id team.id.to_s
  #       end
  #     end
  #   end
  #
  #   json.assignment do
  #     json.data do
  #       json.type "assignments"
  #       json.id assignment.id.to_s
  #     end
  #   end
  #
  #   # TODO: group-graded assignments currently don't show grading buttons?
  # end
end

json.meta do
  json.term_for_assignment term_for :assignment
end
