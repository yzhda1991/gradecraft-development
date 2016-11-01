class EarnedBadgeAwardedPreview
  def earned_badge_awarded
    earned_badge = EarnedBadge.last
    NotificationMailer.earned_badge_awarded earned_badge
  end
end
