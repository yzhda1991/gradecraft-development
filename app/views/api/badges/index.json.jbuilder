json.data @badges do |badge|
  next unless BadgeProctor.new(badge).viewable?(current_user)
  json.partial! 'api/badges/badge', badge: badge
end

json.included do
  if @predicted_earned_badges.present?
    json.array! @predicted_earned_badges do |predicted_earned_badge|
      json.type "predicted_earned_badges"
      json.id predicted_earned_badge.id.to_s
      json.attributes do
        json.id predicted_earned_badge.id
        json.student_id predicted_earned_badge.student_id
        json.predicted_times_earned \
          predicted_earned_badge.times_earned_including_actual
      end
    end
  end

  if @earned_badges.present?
    json.array! @earned_badges do |earned_badge|
      json.type "earned_badges"
      json.id earned_badge.id.to_s
      json.attributes do
        json.merge! earned_badge.attributes
      end
    end
  end
end

json.meta do
  json.term_for_badges term_for :badges
  json.term_for_badge term_for :badge
  json.allow_updates @allow_updates
end
