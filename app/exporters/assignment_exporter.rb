class AssignmentExporter
  def export(assignment, students, options={})
    CSV.generate(options) do |csv|
      csv << headers
    end
  end

  private

  def headers
    ["First Name", "Last Name", "Uniqname", "Score", "Raw Score",
     "Statement", "Feedback", "Last Updated"].freeze
  end
end
