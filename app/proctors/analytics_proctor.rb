# defines the the viewable conditions for analytics
class AnalyticsProctor
  MINIMUM_STUDENT_COUNT = 20

  def viewable?(user, course)
    return true if user.is_staff? course
    course.show_analytics? && (course.student_count >= MINIMUM_STUDENT_COUNT)
  end
end
