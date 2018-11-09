json.data @unlock_conditions do |unlock_condition|
  json.partial! 'api/unlock_conditions/unlock_condition', unlock_condition: unlock_condition
end

# json.meta do
#   json.assignments current_course.assignments.alphabetical.each do |assignment|
#     json.id assignment.id.to_s
#     json.name assignment.name
#     json.pass_fail assignment.pass_fail
#   end

#   json.assignment_types current_course.assignment_types.each do |assignment_type|
#     json.id assignment_type.id
#     json.name assignment_type.name
#   end

#   if current_course.has_badges?
#     json.badges current_course.badges.each do |badge|
#       json.id badge.id
#       json.name badge.name
#     end
#   end

#   json.term_for_assignment_types term_for :assignment_types
#   json.term_for_assignment_type term_for :assignment_type
#   json.term_for_assignments term_for :assignments
#   json.term_for_assignment term_for :assignment
#   json.term_for_badges term_for :badges
#   json.term_for_badge term_for :badge
#   json.term_for_pass term_for :pass
#   json.term_for_fail term_for :fail

#   json.course_id current_course.id
# end
