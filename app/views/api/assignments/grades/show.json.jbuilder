json.data do
  json.type                                 "assignment"
  json.id                                   @assignment.id

  json.attributes do
    json.name                               @assignment.name
    json.pass_fail                          @assignment.pass_fail?
    json.full_points                        @assignment.full_points
    json.grade_checkboxes                   @assignment.grade_checkboxes?
  end
end

# Grades for the assignment
json.included do
  json.array! @grades do |grade|
    json.type                               "grade"
    json.id                                 grade.id

    json.attributes do
      json.student_id                       grade.student.id
      json.student_name                     grade.student.name
      json.raw_points                       grade.raw_points
      json.pass_fail_status                 grade.pass_fail_status || ""
    end
  end
end

json.meta do
  json.term_for_student                     term_for :student
  json.term_for_pass                        term_for :pass
  json.term_for_fail                        term_for :fail
end
