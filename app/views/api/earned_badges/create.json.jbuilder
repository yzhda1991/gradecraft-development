json.data do
  json.type "earned_badges"
  json.id @earned_badge.id.to_s

  json.attributes do
    json.merge! @earned_badge.attributes
  end
end
