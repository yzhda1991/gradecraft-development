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

  def export_badges(badge, students, options={})
    CSV.generate(options) do |csv|
      csv << export_badge_headers
      students.each do |student|
        csv << [student.first_name, student.last_name,
                student.email,
                1]
      end
    end
  end

  private

  def baseline_headers
    ["Badge ID", "Name", "Point Total", "Description", "Times Earned" ]
  end

  def export_badge_headers
    ["First Name", "Last Name", "Email", "Earned"]
  end
end
