module UsersHelper
  def cancel_course_memberships(user)
    user.course_memberships.select(&:marked_for_destruction?).map do |cm|
      Services::CancelsCourseMembership.call(cm)
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

  private

  def raw_flagged_user_icon(flagged)
    raw("<i class=\"fa fa-flag fa-fw #{"flagged" if flagged}\"></i>")
  end
end
