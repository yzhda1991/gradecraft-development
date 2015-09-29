module UsersHelper
  def generate_random_password
    Sorcery::Model::TemporaryToken.generate_random_token
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

    earned_badge_score = user.earned_badges.where(course: course).score
    if earned_badge_score > 0
      scores << { :data => [earned_badge_score], :name => "#{course.badge_term.pluralize}" }
    end

    return {
      :scores => scores,
      :course_total => course.total_points + earned_badge_score
      }
  end
end
