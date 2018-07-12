class CreatedCoursesExporter
  BASELINE_HEADERS = [
    "Course Name", "Student Count", "Published?", "Created At", "Staff Emails"
  ]

  attr_accessor :created_from

  def initialize(created_from = 1.month.ago)
    @created_from = created_from
  end

  def export
    CSV.generate do |csv|
      csv << BASELINE_HEADERS
      courses_created.each do |course|
        csv << [course.formatted_long_name,
          course.students.count,
          course.published? ? "Yes" : "No",
          course.created_at.to_formatted_s,
          staff_emails(course)]
      end
    end
  end

  private

  def courses_created
    Course
      .alphabetical
      .includes(course_memberships: :user)
      .where(created_at: @created_from..DateTime.now)
  end

  def staff_emails(course)
    course.staff.map do |staff|
      "#{staff.name} (#{staff.email})"
    end.join(", ")
  end
end
