COPY (
SELECT
  a.name as assignment_name, u.first_name, u.last_name,
  raw_points, assignment_id, feedback, complete, semis, finals, type, status,
  attempted, substantial, final_points, submission_id, g.course_id, shared,
  student_id, task_id, group_id, group_type, score, g.assignment_type_id,
  g.full_points, admin_notes, graded_by_id, team_id
FROM grades AS g
JOIN users AS u ON g.student_id = u.id
JOIN assignments AS a ON g.assignment_id = a.id
WHERE g.course_id = 3
ORDER BY assignment_id, u.last_name, u.first_name
) TO STDOUT WITH DELIMITER ','
CSV HEADER
