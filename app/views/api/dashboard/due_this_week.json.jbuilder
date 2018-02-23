json.data do
  # arbitrary id to follow JSON API spec, since this data doesn't represent a specific model
  json.id 0
  json.type "dueThisWeekData"

  json.attributes do
    json.type "dueThisWeekData"
    json.has_due_dates @presenter.due_dates?
    json.has_current_student @presenter.student.present?
  end

  json.relationships do
    json.course_planner_assignments do
      json.data @presenter.course_planner_assignments do |assignment|
        json.type "assignments"
        json.id assignment.id
      end
    end

    json.my_planner_assignments do
      json.data @presenter.my_planner_assignments do |assignment|
        json.type "assignments"
        json.id assignment.id
      end
    end if @presenter.student.present?
  end
end

json.included do
  json.array! @presenter.course_planner_assignments do |assignment|
    json.partial! 'api/assignments/assignment', assignment: assignment
  end

  json.array! @presenter.my_planner_assignments do |assignment|
    json.partial! 'api/assignments/assignment', assignment: assignment
  end if @presenter.student.present?
end

json.meta do
  json.term_for_assignment term_for :assignment
  json.term_for_assignments term_for :assignments
end
