json.data @grades[:data] do |grade|
  user = lms_user(@syllabus, grade["user_id"])

  json.type                                   "imported_grade"
  json.id                                     grade["id"].to_s

  json.attributes do
    json.id                                   grade["id"].to_s
    json.primary_email                        user["primary_email"]
    json.score                                grade["score"]
    json.feedback                             grade["submission_comments"]
    json.gradecraft_score                     Grade.for_student_email_and_assignment_id(user["primary_email"],
                                                @assignment.id) || Grade.new
    json.user_exists                          lms_user_match?(user["primary_email"], current_course)
  end
end

json.meta do
  json.term_for_provider_assignment           @provider_assignment["name"]
  json.term_for_assignment                    term_for :assignment
  json.has_next_page                          @grades[:has_next_page]
end
