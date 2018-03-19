json.data do
  # arbitrary id to follow JSON API spec, since this data doesn't represent a specific model
  json.id 0
  json.type "dueThisWeekData"

  json.attributes do
    json.type "dueThisWeekData"
    json.has_due_dates @presenter.due_dates?
    json.has_current_student @presenter.student.present?
    json.current_course_active current_course.active?

    json.predictor_path predictor_path
  end

  json.relationships do
    json.course_planner_assignments @presenter.course_planner_assignments do |assignment|
      json.data do
        json.type "assignments"
        json.id assignment.id.to_s
      end
    end

    json.my_planner_assignments @presenter.my_planner_assignments do |assignment|
      json.data do
        json.type "assignments"
        json.id assignment.id.to_s
      end
    end if @presenter.student.present?
  end
end

# Both students and instructors use this collection
json.included do
  json.array! @presenter.course_planner_assignments do |assignment|
    json.id assignment.id
    json.type "course_planner_assignments"

    json.attributes do
      json.merge! assignment.attributes

      json.due_at_for_current_timezone assignment.due_at.in_time_zone(current_user.time_zone) unless assignment.due_at.nil?
      json.assignment_type_name assignment.assignment_type.name

      json.is_individual assignment.is_individual?

      json.predicted_count assignment.predicted_count
      json.submitted_submissions_count @presenter.submitted_submissions_count(assignment)

      if @presenter.student.present?
        json.submission_link submission_link_to(assignment, @presenter.student)
        json.grade_path grade_path(Grade.find_or_create(assignment.id, @presenter.student.id))
        json.name_visible_for_student assignment.name_visible_for_student? @presenter.student
        json.submitted @presenter.submitted? assignment
        json.starred @presenter.starred? assignment
        json.submittable @presenter.submittable? assignment
      end

      json.assignment_path assignment_path(assignment)
    end
  end

  # Only students use this collection
  json.array! @presenter.my_planner_assignments do |assignment|
    json.id assignment.id
    json.type "my_planner_assignments"

    json.attributes do
      json.merge! assignment.attributes

      json.submittable @presenter.submittable? assignment
      json.due_at_for_current_timezone assignment.due_at.in_time_zone(current_user.time_zone) unless assignment.due_at.nil?
      json.starred @presenter.starred? assignment
      json.submitted @presenter.submitted? assignment
      json.assignment_type_name assignment.assignment_type.name
      json.name_visible_for_student assignment.name_visible_for_student? @presenter.student

      json.submittable @presenter.submittable? assignment
      json.submission_link submission_link_to(assignment, @presenter.student)
      json.is_individual assignment.is_individual?

      if !assignment.is_individual?
        - group = @presenter.student.group_for_assignment(assignment)

        if group.present?
          json.student_group_id group.id
          json.student_group_submitted group.submission_for_assignment(assignment)
          json.student_group_approved group.approved?
          json.new_group_submission_path new_assignment_submission_path(assignment, group_id: group)
        end
      end

      json.assignment_path assignment_path(assignment)
      json.grade_path grade_path(Grade.find_or_create(assignment.id, @presenter.student.id))
    end
  end if @presenter.student.present?
end

json.meta do
  json.term_for_assignment term_for :assignment
  json.term_for_assignments term_for :assignments
  json.term_for_predictor term_for :grade_predictor
end
