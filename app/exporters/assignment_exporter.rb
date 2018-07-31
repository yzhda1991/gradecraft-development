class AssignmentExporter
  attr_accessor :user, :course

  def initialize(current_user, course)
    @course = course
    @user = current_user
  end

  # This format is shared with Assignment import views and functions
  FORMAT = [
    "Name", "Assignment Type", "Point Total", "Description",
    "Purpose", "Open At", "Due At",
    "Accepts Submissions", "Accept Until", "Required"
  ]

  # These headers are not used for import
  ADDITIONAL_HEADERS = [
    "Assignment Id", "Created At", "Submissions Count", "Grades Count", "Learning Objectives"
  ]

  def export
    CSV.generate do |csv|
      csv << FORMAT + ADDITIONAL_HEADERS
      @course.assignments.each do |a|
        csv << [
          a.name,
          a.assignment_type.name,
          a.full_points,
          a.description,
          a.purpose,
          formatted_date(a.open_at),
          formatted_date(a.due_at),
          a.accepts_submissions,
          formatted_date(a.accepts_submissions_until),
          a.required,
          a.id,
          formatted_date(a.created_at),
          a.submissions.submitted.count,
          a.grades.student_visible.count,
          a.learning_objectives.pluck(:name).join(',')
        ]
      end
    end
  end

  private

  def formatted_date(date)
    return nil if date.nil?
    date.in_time_zone(@user.time_zone).strftime("%d/%m/%Y")
  end
end
