json.data do
  json.type "predicted_earned_grades"
  json.id @prediction.id.to_s

  json.attributes do
    json.merge! @prediction.attributes
  end
end
