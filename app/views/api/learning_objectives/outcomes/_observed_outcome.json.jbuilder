json.type "learning_objective_observed_outcome"
json.id outcome.id

json.attributes do
  json.merge! outcome.attributes
  json.grade_id outcome.grade.try(:id)
end
