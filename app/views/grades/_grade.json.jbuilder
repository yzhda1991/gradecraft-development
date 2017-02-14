json.(grade, :id, :status, :raw_points, :feedback, :student_id,
  :assignment_id)

json.student_visible GradeProctor.new(grade).viewable?

json.assignment do
  json.release_necessary assignment.release_necessary
end
