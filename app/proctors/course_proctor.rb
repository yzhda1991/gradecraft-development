# determines what sort of CRUD operations can be performed
# on a `course` resource
class CourseProctor

  attr_reader :course

  def initialize(course)
    @course = course
  end

  def viewable?(user)
    return false if course.nil? || user.nil?
    user.courses.include? @course
  end

  def updatable?(user)
    return false if course.nil? || user.nil?
    user.is_staff?(course) || user.is_admin?(course)
  end

  # Defines whether the user has the ability to publish the course
  def publishable?(user)
    return true unless Rails.env.beta?
    return true if user.is_admin? @course
    @course.has_paid?
  end

  def destroyable?(user)
    return false if course.nil? || user.nil?
    user.is_admin?(course)
  end
end
