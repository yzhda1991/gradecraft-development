json.points_by_assignment_type @assignment_types do |assignment_type|
  json.name assignment_type.name
  json.points assignment_type.visible_score_for_student(@student)
end

json.earned_badge_points do
  json.name current_course.badge_term.pluralize
  json.points @earned_badge_points
end

json.course_potential_points_for_student @course_potential_points_for_student

json.meta do
  json.term_for_assignment term_for :assignment
  json.term_for_assignments term_for :assignments
  json.term_for_badge term_for :badge
  json.term_for_badges term_for :badges
  json.term_for_pass term_for :pass
  json.term_for_fail term_for :fail
end
