module UsersHelper
  def cancel_course_memberships(user)
    user.course_memberships.select(&:marked_for_destruction?).map do |cm|
      Services::CancelsCourseMembership.for_student(cm)
    end
  end

  def flagged_users_icon(flagged_users, flagged_id)
    flagged = flagged_users.any? { |f| f.flagged_id == flagged_id }
    raw_flagged_user_icon flagged
  end

  def flagged_user_icon(course, flagger, flagged_id)
    flagged = FlaggedUser.flagged? course, flagger, flagged_id
    raw_flagged_user_icon flagged
  end

  def total_scores_for_chart(user, course)
    scores = []
    course.assignment_types.each do |assignment_type|
      scores << { data: assignment_type.visible_score_for_student(user),
                  name: assignment_type.name }
    end

    earned_badge_points = user.earned_badges.sum(&:points)
    if earned_badge_points > 0
      scores << { data: [earned_badge_points], name: "#{course.badge_term.pluralize}" }
    end

    return {
      scores: scores,
      course_total: course.total_points + earned_badge_points
      }
  end

  private

  def raw_flagged_user_icon(flagged)
    raw("<i class=\"fa fa-flag fa-fw #{"flagged" if flagged}\"></i>")
  end
end
