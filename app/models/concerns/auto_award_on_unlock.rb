module AutoAwardOnUnlock
  extend ActiveSupport::Concern

  def award_badge(unlock_state, earned_badge_attr)
    return unless unlock_state.unlocked?
    return unless unlock_state.unlockable_type == "Badge"
    return unless unlock_state.unlockable.auto_award_after_unlock?

    earned_badge_attr.merge!(feedback: "Auto-awarded on #{DateTime.now}") if attributes[:feedback].nil?
    Services::CreatesEarnedBadge.call earned_badge_attr.merge(
      student_visible: true,
      badge_id: unlock_state.unlockable_id
    )
  end
end
