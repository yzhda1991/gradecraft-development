json.data @submissions do |submission|
  json.id submission.id
  json.type "submissions"

  json.attributes do
    json.student_id submission.student_id
    json.assignment_id submission.assignment_id

    json.graded submission.has_grade?

    if submission.has_grade?
      json.grade_id submission.submission_grade.id
    end
  end
end
