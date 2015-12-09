
  def self.csv_assignments
    CSV.generate() do |csv|
      csv << ["ID", "Name", "Point Total", "Description", "Open At", "Due At", "Accept Until"  ]
      assignments.each do |assignment|
        csv << [ assignment.id, assignment.name, assignment.point_total, assignment.description, assignment.open_at, assignment.due_at, assignment.accepts_submissions_until  ]
      end
    end
  end
