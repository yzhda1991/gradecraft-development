json.type "learning_objective_level"
json.id level.id

json.attributes do
  json.merge! level.attributes
  json.readable_flagged_value level.readable_flagged_value
  json.updated_at level.updated_at
end
