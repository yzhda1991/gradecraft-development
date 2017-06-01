json.data do
  json.type                                 "assignment"
  json.id                                   @assignment.id

  json.attributes do
    json.name                               @assignment.name
    json.pass_fail                          @assignment.pass_fail?
    json.has_levels                         @assignment.has_levels?
    json.assignment_score_level_count       @assignment.assignment_score_levels.count if @assignment.has_levels?
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
      json.id                               grade.id
      json.student_id                       grade.student.id
      json.student_name                     grade.student.name
      json.raw_points                       grade.raw_points
      json.pass_fail_status                 grade.pass_fail_status
      json.student_id                       grade.student_id
    end
  end

  json.array! @assignment.assignment_score_levels do |level|
    json.type                               "assignment_score_level"
    json.id                                 level.id

    json.attributes do
      json.name                             level.name
      json.points                           level.points
      json.formatted_name                   level.formatted_name
    end
  end if @assignment.has_levels?
end

json.meta do
  json.term_for_student                     term_for :student
  json.term_for_pass                        term_for :pass
  json.term_for_fail                        term_for :fail
end
