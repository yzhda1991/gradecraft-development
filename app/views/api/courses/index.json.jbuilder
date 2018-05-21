json.data @courses do |course|
  if current_user_is_admin?
    json.partial! "api/courses/course", course: course
  else
    json.type "courses"
    json.id course.id.to_s

    json.attributes do
      json.partial! "api/courses/course_search_attributes", course: course
    end
  end
end

json.included do
  json.array! User.with_role_in_courses("staff", @courses) do |staff_member|
    json.type "staff"
    json.id staff_member.id.to_s

    json.attributes do
      json.name staff_member.name
    end
  end
end

json.meta do
  json.term_for_badges term_for :badges
  json.term_for_assignment term_for :assignment
  json.term_for_assignments term_for :assignments
  json.term_for_assignment_type term_for :assignment_type
end
