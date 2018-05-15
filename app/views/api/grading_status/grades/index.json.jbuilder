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
    end

    grade.assignment.tap do |assignment|
      json.assignment_id assignment.id
      json.assignment_name assignment.name
      json.assignment_has_groups assignment.has_groups?
      json.assignment_path assignment_path(assignment)

      grade.group.tap do |group|
        if assignment.has_groups?
          json.group_name group.try(:name)
          json.group_path group_path(group)
        end
        json.edit_group_grade_link edit_group_grade_link_to(assignment, group, class: "button")
      end unless grade.group.nil?
    end

    grade.student.tap do |student|
      team = student.team_for_course(current_course)

      json.student_name student.name
      json.student_path student_path(student)

      unless team.nil?
        json.team_name team.name
        json.team_path team_path(team)
      end
    end
  end
end
