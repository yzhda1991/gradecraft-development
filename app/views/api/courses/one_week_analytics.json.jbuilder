json.data "sam i am"

if @student.present?
  json.student_name @student.name
end

if current_user_is_staff?
  json.faculty_info "Include all course info for week"
end
