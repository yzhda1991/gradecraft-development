module GradeAbility
  def define_grade_abilities(user, course)
    can :read, Grade do |grade|
      GradeProctor.new(grade).viewable? user, course
    end

    can :update, Grade do |grade|
      GradeProctor.new(grade).updatable? user, course
    end
  end
end
