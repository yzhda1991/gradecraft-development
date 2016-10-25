module UsersHelper
  def cancel_course_memberships(user)
    user.course_memberships.select(&:marked_for_destruction?).map do |cm|
      Services::CancelsCourseMembership.for_student(cm)
    end
  end

  def flagged_user_icon(course, flagger, flagged_id)
    flagged = FlaggedUser.flagged? course, flagger, flagged_id
    raw("<i class=\"fa fa-flag fa-fw #{"flagged" if flagged}\"></i>")
  end

  def total_scores_for_chart(user, course)
    scores = []
    course.assignment_types.each do |assignment_type|
      scores << { data: [assignment_type.visible_score_for_student(user)],
                  name: assignment_type.name }
    end

    earned_badge_points = user.earned_badges.inject(0) {|sum, eb| sum + eb.points}
    if earned_badge_points > 0
      scores << { data: [earned_badge_points], name: "#{course.badge_term.pluralize}" }
    end

    return {
      scores: scores,
      course_total: course.total_points + earned_badge_points
      }
  end
end
