json.type "unlock_condition"
json.id unlock_condition.id.to_s

json.attributes do
  json.merge! unlock_condition.attributes
end
