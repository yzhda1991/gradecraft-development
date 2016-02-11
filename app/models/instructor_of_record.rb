class InstructorOfRecord
  attr_reader :course

  def initialize(course)
    @course = course
  end

  def update_course_memberships(user_ids)
    not_instructors_of_record(user_ids).map do |membership|
      membership.update_attributes instructor_of_record: true
      membership
    end
  end

  private

  def not_instructors_of_record(user_ids)
    course.course_memberships.select do |membership|
      user_ids.include?(membership.user_id) && !membership.instructor_of_record?
    end
  end
end
