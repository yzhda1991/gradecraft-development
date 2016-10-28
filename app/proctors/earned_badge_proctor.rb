# determines what sort of CRUD operations can be performed
# on a `earned_badge` resource
class EarnedBadgeProctor

  attr_reader :earned_badge

  def initialize(earned_badge)
    @earned_badge = earned_badge
  end

  def buildable?(user)
    course.users.include?(user) && (
      user.is_staff?(course) || (
        earned_badge.badge.student_awardable? &&
        user.is_student?(course)
      )
    )
  end

  def creatable?(user)
    buildable?(user) &&
    course.students.include?(earned_badge.student) &&
    earned_badge.student != user
  end

  private

  def course
    earned_badge.course || earned_badge.badge.course
  end
end
