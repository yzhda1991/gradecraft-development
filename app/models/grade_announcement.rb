class GradeAnnouncement
  def self.create(grade)
    new(grade).create_announcement
  end

  def create_announcement
    Announcement.create params
  end

  protected

  attr_reader :grade

  def initialize(grade)
    @grade = grade
  end

  def body
    url = Rails.application.routes.url_helpers.assignment_url(
      grade.assignment,
      Rails.application.config.action_mailer.default_url_options)

    "<p>You can now view the grade for your #{grade.course.assignment_term.downcase} " \
      "#{grade.assignment.name} in #{grade.course.name}.</p>" \
      "<p>Visit <a href=#{url}>#{grade.assignment.name}</a> to view your results.</p>"
  end

  def params
    { course_id:    grade.course_id,
      author_id:    grade.graded_by_id,
      recipient_id: grade.student_id,
      body:         body,
      title:        title
    }
  end

  def title
    "#{grade.course.course_number} - #{grade.assignment.name} Graded"
  end
end
