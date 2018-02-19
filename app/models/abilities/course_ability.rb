module CourseAbility
  def define_course_abilities(user)
    can :read, Course do |course|
      CourseProctor.new(course).viewable? user
    end

    can :update, Course do |course|
      CourseProctor.new(course).updatable? user
    end

    can :publish, Course do |course|
      CourseProctor.new(course).publishable? user
    end

    can :destroy, Course do |course|
      CourseProctor.new(course).destroyable? user
    end
  end
end
