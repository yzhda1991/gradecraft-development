json.badges @badges do |badge|
  next unless badge.visible
  next unless badge.point_total && badge.point_total > 0
  json.merge! badge.attributes
  json.icon badge.icon.url
  json.predicted_score 0
  json.info ! badge.description.blank?
end

json.term_for_badges term_for :badges
