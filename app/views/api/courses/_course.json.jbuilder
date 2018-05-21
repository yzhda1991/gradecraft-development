json.type "courses"
json.id course.id.to_s

json.attributes do
  json.partial! "api/courses/course_search_attributes", course: course

  json.active course.active?
  json.published course.published?
  json.has_badges course.has_badges?
  json.has_teams course.has_teams?
  json.has_paid course.has_paid?

  json.name course.name
  json.semester course.semester
  json.year course.year
  json.course_number course.course_number

  json.total_points course.total_points
  json.formatted_total_points points course.total_points

  json.student_count course.student_count

  # relative to current user's timezone
  course.created_at.in_time_zone(current_user.time_zone).tap do |created_at|
    json.created_at created_at
    json.formatted_created_at l created_at
  end

  json.edit_course_path edit_course_path course
  # TODO: these routes that post/delete, ask for confirmation, and disable after click
  # json.copy_courses_path id: course.id
  # json.copy_courses_path id: course.id, copy_type: "with_students"
  # json.course_path course_path course
  json.change_course_path change_course_path course

  json.research_gradebook_path research_gradebook_path id: course.id, format: :csv
  json.final_grades_path final_grades_path id: course.id, format: :csv
  json.submissions_path submissions_path id: course.id, format: :csv
  json.gradebook_file_path gradebook_file_path id: course.id, format: :csv
  json.multiplied_gradebook_path multiplied_gradebook_path id: course.id, format: :csv

  json.export_earned_badges_path export_earned_badges_path id: course.id, format: :csv
  json.export_all_scores_assignment_types_path export_all_scores_assignment_types_path id: course.id, format: :csv
  json.export_structure_assignments_path export_structure_assignments_path id: course.id, format: :csv
  json.export_structure_badges_path export_structure_badges_path id: course.id, format: :csv
  json.export_structure_grade_scheme_elements_path export_structure_grade_scheme_elements_path id: course.id, format: :csv
end

json.relationships do
  json.staff do
    json.data course.staff do |staff_member|
      json.type "staff"
      json.id staff_member.id.to_s
    end
  end if course.staff.any?
end
