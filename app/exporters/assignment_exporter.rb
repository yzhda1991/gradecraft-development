class AssignmentExporter
  def export(course)
    CSV.generate do |csv|
      csv << baseline_headers
      course.assignments.each do |assignment|
        csv << [ assignment.id, assignment.name, assignment.assignment_type.name,
          assignment.full_points, assignment.description, assignment.open_at,
          assignment.due_at, assignment.accepts_submissions_until,
          assignment.submissions.submitted.count, assignment.grades.student_visible.count, assignment.created_at, assignment.learning_objectives.pluck(:name).join(',') ]
      end
    end
  end

  private

  def baseline_headers
    ["Assignment ID", "Name", "Assignment Type", "Point Total", "Description", "Open At",
      "Due At", "Accept Until", "Submissions Count", "Grades Count", "Created At", "Learning Objectives" ]
  end
end
