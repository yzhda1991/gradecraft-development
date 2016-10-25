module Services
  module Actions
    class NotifiesOfEarnedBadge
      extend LightService::Action

      expects :earned_badge

      executed do |context|
        earned_badge = context.earned_badge
        if earned_badge.student_visible?
          Announcement.create course_id: earned_badge.course_id,
            author_id: earned_badge.awarded_by_id,
            body: announcement_body(earned_badge),
            title: "#{earned_badge.course.course_number} - "\
                   "You've earned a new #{earned_badge.course.badge_term}!"

          NotificationMailer.earned_badge_awarded(earned_badge.id).deliver_now
        end
      end

      protected

      def self.announcement_body(earned_badge)
        url = Rails.application.routes.url_helpers.course_badge_earned_badge_url(
          earned_badge.course,
          earned_badge.badge,
          earned_badge,
          Rails.application.config.action_mailer.default_url_options)

        "<p>Congratulations #{earned_badge.student.first_name}!</p>" \
          "<p>You've earned the #{earned_badge.badge.name} #{earned_badge.course.badge_term}.</p>" \
          "<p>Check out your new <a href='#{url}'>#{earned_badge.course.badge_term.downcase}</a>.</p>"
      end
    end
  end
end
