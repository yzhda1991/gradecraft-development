json.data do
  return if @badge.course != current_course
  json.partial! 'api/badges/badge', badge: @badge
end

json.meta do
  json.term_for_badges term_for :badges
  json.term_for_badge term_for :badge
end
