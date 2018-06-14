class AssignmentExporter

  FORMAT = [
      "Name", "Assignment Type", "Point Total", "Description",
      "Assignment Purpose", "Open At", "Due At", "Accepts Submissions", "Accept Until",
      "Submissions Count", "Grades Count", "Created At", "Required", "Learning Objectives"
    ].freeze

  def export(course)
    CSV.generate do |csv|
      csv << FORMAT
      course.assignments.each do |a|
        csv << [
          a.name, a.assignment_type.name, a.full_points, a.description,
          a.purpose, a.open_at, a.due_at, a.accepts_submissions, a.accepts_submissions_until,
          a.submissions.submitted.count, a.grades.student_visible.count, a.created_at, a.required,
          a.learning_objectives.pluck(:name).join(',')
        ]
      end
    end
  end
end
