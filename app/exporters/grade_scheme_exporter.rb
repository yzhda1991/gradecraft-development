class GradeSchemeExporter
  def export(course)
    CSV.generate do |csv|
      csv << baseline_headers
      course.grade_scheme_elements.each do |gse|
        csv << [gse.id, gse.letter, gse.level, gse.lowest_points]
      end
    end
  end

  private

  def baseline_headers
    ["Level ID", "Letter Grade", "Level Name", "Lowest Points"]
  end
end
