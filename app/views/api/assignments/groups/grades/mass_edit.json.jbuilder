json.data do
  json.type                                 "assignment"
  json.id                                   @assignment.id

  json.attributes do
    json.name                               @assignment.name
    json.pass_fail                          @assignment.pass_fail?
    json.has_levels                         @assignment.has_levels?
    json.assignment_score_level_count       @assignment.assignment_score_levels.count if @assignment.has_levels?
    json.full_points                        @assignment.full_points
  end
end

# Grades for the assignment by group
json.included do
  json.array! @grades_by_group do |gbg|
    json.type                               "group_grade"
    json.id                                 gbg[:group].id

    json.attributes do
      json.group_id                         gbg[:group].id
      json.group_name                       gbg[:group].name
      json.raw_points                       gbg[:grade].raw_points
      json.pass_fail_status                 gbg[:grade].pass_fail_status
      json.graded                           gbg[:grade].persisted?
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
  json.term_for_pass                        term_for :pass
  json.term_for_fail                        term_for :fail
end
