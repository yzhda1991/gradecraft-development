module UnlockConditionHelper
  def check_unlocked_for(unlock_condition)
    case unlock_condition.condition_state
    when "Submitted"
      trigger_unlock_check_for unlock_condition, :submissions
    when "Grade Earned", "Feedback Read", "Passed", "Assignments Completed"
      trigger_unlock_check_for unlock_condition, :grades
    when "Earned" || condition_state == "Minimum Points Earned"
      trigger_unlock_check_for_earned_condition unlock_condition
    else
      raise ArgumentError, "Unknown condition state found (#{unlock_condition.condition_state})"
    end
  end

  private

  def trigger_unlock_check_for_earned_condition(unlock_condition)
    case unlock_condition.condition_type
    when "Badge"
      trigger_unlock_check_for unlock_condition, :earned_badges
    when "Course"
      trigger_unlock_check_for unlock_condition, :course_memberships
    else
      trigger_unlock_check_for unlock_condition, :grades
    end
  end

  # e.g.
  # when (unlock_condition.condition_type == 'Assignment')
  #   assignment.submissions.check_unlockables
  #   assignment.grades.check_unlockables
  # when (unlock_condition.condition_type == 'Badge')
  #   badge.earned_badges.check_unlockables
  # when (unlock_condition.condition_type == 'Course')
  #   course.course_memberships.check_unlockables
  def trigger_unlock_check_for(unlock_condition, grade_type)
    course = unlock_condition.course
    unlock_condition.condition.send(grade_type).each(&:check_unlockables)
  end
end
