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

  def export_sample_badge_file(badge, current_course, options={})
    CSV.generate(options) do |csv|
      csv << export_badge_headers
      current_course.students_being_graded.each do |student|
        csv << [student.first_name,
          student.last_name,
          student.email,
          current_course.earned_badges.where(student_id: student.id, badge_id: badge.id).count,
          1,
          "Awesome Job!"]
      end
    end
  end

  private

  def baseline_headers
    ["Badge ID", "Name", "Point Total", "Description", "Times Earned" ]
  end

  def export_badge_headers
    ["First Name", "Last Name", "Email", "Current Earned Count", "New Awarded Count", "Feedback (optional)"].freeze
  end
end
