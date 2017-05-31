json.course_id @course.id
json.scores @scores
json.user_score @user_score
json.is_here current_user.present? && current_student.present?
