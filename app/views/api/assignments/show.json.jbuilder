json.data do
  return if @assignment.course != current_course

  json.partial! 'api/assignments/assignment', assignment: @assignment
end

json.meta do
  json.term_for_assignment term_for :assignment
  json.term_for_pass current_course.pass_term
  json.term_for_fail current_course.fail_term
end
