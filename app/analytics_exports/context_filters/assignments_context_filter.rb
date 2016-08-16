class AssignmentsContextFilter < Analytics::Export::ContextFilter

  # only filter instances of CourseExportContext
  accepts_context_types :course_export_context

  def assignment_names
    @assignment_names ||= assignments.inject({}) do |memo, assignment|
      memo[assignment.id] = assignment.name
      memo
    end
  end
end
