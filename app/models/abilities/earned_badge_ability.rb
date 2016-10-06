module EarnedBadgeAbility
  def define_earned_badge_abilities(user)
    can :new, EarnedBadge do |earned_badge|
      EarnedBadgeProctor.new(earned_badge).newable? user
    end

    can :create, EarnedBadge do |earned_badge|
      EarnedBadgeProctor.new(earned_badge).creatable? user
    end
  end
end
