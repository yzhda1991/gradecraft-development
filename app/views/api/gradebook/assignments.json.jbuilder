json.data @assignments do |assignment|
  json.type "assignment"
  json.id assignment[:id]

  json.attributes do
    json.id assignment[:id]
    json.name assignment[:name]
  end
end

json.meta do
  json.term_for_badge current_course.badge_term
  json.term_for_student current_course.student_term
end
