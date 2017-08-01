json.data do
  return if @badge.course != current_course
  json.partial! 'api/badges/badge', badge: @badge
end

json.included do
  if @badge.badge_files.present?
    json.array! @badge.badge_files do |badge_file|
      json.type "file_uploads"
      json.id badge_file.id.to_s
      json.attributes do
        json.id badge_file.id
        json.badge_id badge_file.badge_id
        json.filename badge_file.filename
      end
    end
  end
end

json.meta do
  json.term_for_badges term_for :badges
  json.term_for_badge term_for :badge
end
