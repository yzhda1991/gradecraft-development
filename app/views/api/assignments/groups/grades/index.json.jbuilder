json.data do
  json.array! @groups do |group|
    json.type "groups"
    json.id group.id

    json.attributes do
      json.id group.id
      json.name group.name
      json.approved group.approved

      json.student_ids group.students.pluck(:student_id)

      json.has_group_submission group.submission_for_assignment(@assignment).present?

      json.group_path group_path(group)
      json.edit_group_path edit_group_path(group)
      json.new_submission_path new_assignment_submission_path(@assignment, group_id: group.id)

      # Fully-formed html for link, generated from LinkHelper class
      json.edit_group_grade_link edit_group_grade_link_to(@assignment, group, class: "button")

      json.has_unreleased_grades group.grades.not_released.any?
      json.grade_assignment_path grade_assignment_group_path(@assignment, group)
    end

    json.relationships do
      json.grades do
        json.data @group_grades[group.id] do |grade|
          json.type "grades"
          json.id grade.id
        end
      end
    end
  end
end

json.included do
  json.array! @group_grades.values.flatten do |grade|
    json.type "grades"
    json.id grade.id

    json.attributes do
      json.student_id grade.student_id
      json.score grade.score

      json.complete grade.complete?
      json.student_visible grade.student_visible?
      json.not_released grade.not_released?

      json.final_points points(grade.try(:final_points))
      json.earned_grade_level @assignment.grade_level(grade)
      json.pass_fail_status term_for(grade.pass_fail_status) unless grade.pass_fail_status.nil?
      json.graded grade.persisted?
      json.instructor_modified grade.instructor_modified?

      if grade.persisted?
        json.id grade.id
        json.grade_path grade_path(grade)
      end

      unless grade.student.nil?
        json.student_name grade.student.name
        json.student_path student_path(grade.student)
      end
    end
  end
end

json.meta do
  json.term_for_group term_for :group
  json.term_for_groups term_for :groups
  json.term_for_students current_course.student_term.pluralize
end
