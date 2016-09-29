module EarnedBadgeAbility
  def define_earned_badge_abilities(user)
    can :create, EarnedBadge do |earned_badge|
      user.is_staff?(earned_badge.course) || (
        earned_badge.badge.student_awardable? &&
        earned_badge.student != user
      )
    end
  end
end
