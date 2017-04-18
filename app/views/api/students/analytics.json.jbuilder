json.points_by_assignment_type @assignment_types do |assignment_type|
  json.name assignment_type.name
  json.points assignment_type.visible_score_for_student(@student)
end

json.earned_badge_points do
  json.name current_course.badge_term.pluralize
  json.points @earned_badge_points
end

json.course_potential_for_student @course_potential_for_student
