json.participation_rate @assignment.participation_rate
json.assignment_score_frequency @assignment.score_frequency
json.scores @assignment.student_visible_scores
json.user_score @user_score
json.assignment_average @assignment.average
json.assignment_median @assignment.median
json.assignment_low_score @assignment.low_score
json.assignment_high_score @assignment.high_score

json.meta do
  json.term_for_assignment term_for :assignment
  json.term_for_assignments term_for :assignments
end
