module GradeAbility
  def define_grade_abilities(user, course)
    can :read, Grade do |grade|
      GradeProctor.new(grade).viewable? user: user, course: course
    end

    can :update, Grade do |grade|
      GradeProctor.new(grade).updatable? user: user, course: course
    end
  end
end
