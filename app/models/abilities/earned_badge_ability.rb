module EarnedBadgeAbility
  def define_earned_badge_abilities(user)
    can :create, EarnedBadge do |earned_badge|
      EarnedBadgeProctor.new(earned_badge).creatable? user
    end
  end
end
