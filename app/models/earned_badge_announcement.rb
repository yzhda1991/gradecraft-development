class EarnedBadgeAnnouncement
  def self.create(earned_badge)
    new(earned_badge).create_announcement
  end

  def create_announcement
    Announcement.create params
  end

  protected

  attr_reader :earned_badge

  def initialize(earned_badge)
    @earned_badge = earned_badge
  end

  def body
    url = Rails.application.routes.url_helpers.course_badge_earned_badge_url(
      earned_badge.course,
      earned_badge.badge,
      earned_badge,
      Rails.application.config.action_mailer.default_url_options)

    "<p>Congratulations #{earned_badge.student.first_name}!</p>" \
      "<p>You've earned the #{earned_badge.badge.name} #{earned_badge.course.badge_term}.</p>" \
      "<p>Check out your new <a href='#{url}'>#{earned_badge.course.badge_term.downcase}</a>.</p>"
  end

  def params
    { course_id: earned_badge.course_id,
      author_id: earned_badge.awarded_by_id,
      body:      body,
      title:     title
    }
  end

  def title
    "#{earned_badge.course.course_number} - "\
      "You've earned a new #{earned_badge.course.badge_term}!"
  end
end
