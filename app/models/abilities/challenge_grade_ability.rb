module ChallengeGradeAbility
  def define_challenge_grade_abilities(user, course)
    can :read, ChallengeGrade do |challenge_grade|
      ChallengeGradeProctor.new(challenge_grade).viewable? user: user, course: course
    end

    can :destroy, Grade do |grade, options|
      GradeProctor.new(grade).destroyable? (options || {})
        .merge({ user: user, course: course })
    end
  end
end
