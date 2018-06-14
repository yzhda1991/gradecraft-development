class AssignmentExporter

  # This format is shared with Assignment import views and functions
  FORMAT = [
    "Name", "Assignment Type", "Point Total", "Description",
    "Assignment Purpose", "Open At", "Due At",
    "Accepts Submissions", "Accept Until", "Required"
  ]

  # These headers are not used for import
  ADDITIONAL_HEADERS = [
   "Assignment Id", "Created At", "Submissions Count", "Grades Count", "Learning Objectives"
  ]

  def export(course)
    CSV.generate do |csv|
      csv << FORMAT + ADDITIONAL_HEADERS
      course.assignments.each do |a|
        csv << [
          a.name, a.assignment_type.name, a.full_points, a.description,
          a.purpose, a.open_at, a.due_at,
          a.accepts_submissions, a.accepts_submissions_until, a.required,
          a.id, a.created_at, a.submissions.submitted.count, a.grades.student_visible.count,
          a.learning_objectives.pluck(:name).join(',')
        ]
      end
    end
  end
end
