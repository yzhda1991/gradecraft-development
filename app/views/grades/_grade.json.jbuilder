 json.(grade, :id, :status, :raw_score, :feedback, :is_custom_value, :student_id, :assignment_id)
 json.assignment do
   json.release_necessary assignment.release_necessary
 end