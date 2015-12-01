class CourseMembershipBuilder
  attr_reader :builder

  def initialize(builder)
    @builder = builder
  end

  def build_for(user, role="student")
    builder.courses.map do |course|
      if user.course_memberships.map(&:course_id).none? { |id| id == course.id }
        user.course_memberships.build course_id: course.id, role: role
      end
    end
  end
end
