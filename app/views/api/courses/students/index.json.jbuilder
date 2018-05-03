current_rank = 0

json.data @students do |student|
  student_earned_badges = @earned_badges.student_visible.order_by_created_at.for_student student
  team = student.team_for_course @course

  json.id student.id.to_s
  json.type "users"

  json.attributes do
    json.id student.id.to_s

    json.name student.name
    json.email student.email
    json.first_name student.first_name
    json.last_name student.last_name
    json.full_name student.name
    json.display_name student.display_name(current_course)
    json.avatar_file_name_url student.avatar_file_name_url
    json.search_string student.searchable_name

    json.activated student.activated?
    json.flagged @flagged_users.any? { |f| f.flagged_id == student.id }

    json.earned_badge_count student_earned_badges.count

    json.deleteable !student.grades.where(course_id: @course.id).present? &&
      !student.submissions.where(course_id: @course.id).present?

    student.last_activity_at.in_time_zone(current_user.time_zone).tap do |last_activity|
      json.last_activity_date last_activity
      json.formatted_last_activity_date l last_activity
    end unless student.last_activity_at.nil?

    current_course.course_memberships.find_by(user: student).tap do |membership|
      json.course_membership_id membership.id
      json.auditing membership.auditing?
      json.activated_for_course membership.active?
      json.team_role membership.team_role if current_course.has_team_roles?

      (membership.score || 0).tap do |score|
        json.score score
        json.formatted_score points(membership.score || 0)
      end

      json.earned_grade_scheme_element (membership.grade_scheme_element ||
        membership.earned_grade_scheme_element).try(:name)
    end

    unless team.nil?
      json.team_id team.id.to_s
      json.team_name team.name  # redundant, but used for sorting
    end

    json.student_path student_path(student)
    json.edit_path edit_user_path(student)
    json.preview_path student_preview_path(student)
    json.manual_activation_path manually_activate_user_path(student)
    json.resend_activation_email_path resend_activation_email_user_path(student)
  end

  json.relationships do
    json.teams do
      json.data do
        json.id team.id.to_s
        json.type "teams"
      end
    end unless team.nil?

    student_earned_badges.tap do |seb|
      json.earned_badges do
        json.data do
          json.array! seb do |earned_badge|
            json.id earned_badge.id.to_s
            json.type "earned_badges"
          end
        end
      end
    end
  end
end

json.included do
  json.array! @teams do |team|
    json.id team.id.to_s
    json.type "teams"

    json.attributes do
      json.id team.id.to_s
      json.name team.name
      json.team_path team_path(team.id)
    end
  end if @teams.present?

  json.array! @earned_badges do |earned_badge|
    json.id earned_badge.id.to_s
    json.type "earned_badges"

    json.attributes do
      json.student_id earned_badge.student_id.to_s

      earned_badge.badge.tap do |badge|
        json.badge_icon_url badge.icon_url
        json.badge_name badge.name
      end
    end
  end
end

json.meta do
  json.term_for_student term_for :student
  json.term_for_students term_for :students
end
