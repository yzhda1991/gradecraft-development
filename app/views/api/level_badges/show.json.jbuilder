json.data do
  json.type "level_badges"
  json.id @level_badge.id.to_s
  json.attributes do
    json.merge! @level_badge.attributes
  end
end
