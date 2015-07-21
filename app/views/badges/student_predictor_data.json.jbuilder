json.badges @badges do |badge|
  next unless badge.visible
  next unless badge.point_total && badge.point_total > 0
  json.merge! badge.attributes
end

json.term_for_badge term_for :badge
