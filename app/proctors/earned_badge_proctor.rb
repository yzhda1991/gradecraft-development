# determines what sort of CRUD operations can be performed
# on a `earned_badge` resource
class EarnedBadgeProctor

  attr_reader :earned_badge

  def initialize(earned_badge)
    @earned_badge = earned_badge
  end

  def creatable?(user)
    return false unless earned_badge.course.users.include? user
    return false unless earned_badge.student.nil? || earned_badge.course.students.include?(earned_badge.student)

    user.is_staff?(earned_badge.course) || (
      earned_badge.badge.student_awardable? &&
      earned_badge.student != user
    )
  end
end
