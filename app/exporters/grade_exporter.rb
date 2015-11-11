class GradeExporter
  def export(assignment, students, options={})
    data = CSV.generate(options) do |csv|
      csv << headers
    end
    CSV.new data
  end

  private

  def headers
    ["First Name", "Last Name", "Email", "Score", "Feedback"].freeze
  end
end
