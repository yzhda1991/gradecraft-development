class AssignmentExporter
  def export(course)
    CSV.generate do |csv|
      csv << baseline_headers
      course.assignments.each do |assignment|
        csv << [ assignment.id, assignment.name, assignment.full_points,
          assignment.description, assignment.open_at, assignment.due_at,
          assignment.accepts_submissions_until, assignment.submissions.submitted.count  ]
      end
    end
  end

  private

  def baseline_headers
    ["Assignment ID", "Name", "Point Total", "Description", "Open At",
      "Due At", "Accept Until", "Submissions Total" ]
  end
end
