if @student.present?
  json.student_data do
    json.student_name @student.name
    json.points_this_week @student.points_earned_for_course_this_week(current_course)
    json.grades_this_week @student.grades_released_for_course_this_week(current_course) do |grade|
      json.assignment       grade.assignment.name
      json.url              assignment_path grade.assignment
      json.pass_fail_status grade.pass_fail_status
      json.final_points     grade.final_points
    end

    json.badges_this_week @student.earned_badges_for_course_this_week(current_course) do |badge|
      json.name badge.name
      json.icon badge.icon.url
    end
  end
end

if current_user_is_staff?
  json.faculty_data do
    json.submissions_this_week current_course.submitted_assignment_types_this_week do |at|
      json.assignment_type at.name
      json.count Submission.submitted_this_week(at).count
    end

    json.badges_this_week current_course.badges.earned_this_week do |badge|
      json.name badge.name
      json.icon badge.icon.url
      json.count badge.earned_badges_this_week_count
    end
  end
end

json.meta do
  json.term_for_assignment term_for :assignment
  json.term_for_pass term_for :pass
  json.term_for_fail term_for :fail
end
