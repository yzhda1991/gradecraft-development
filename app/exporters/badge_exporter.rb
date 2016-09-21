class BadgeExporter
  def export(course)
    CSV.generate do |csv|
      csv << baseline_headers
      course.badges.each do |badge|
        csv << [ badge.id, badge.name, badge.full_points,
          badge.description, badge.earned_count ]
      end
    end
  end

  private

  def baseline_headers
    ["Badge ID", "Name", "Point Total", "Description", "Times Earned" ]
  end
end
