class BreadcrumbTrail < Croutons::BreadcrumbTrail
  
  def analytics_students
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Student Analytics", analytics_students_path)
  end
  
  def analytics_staff
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Staff Analytics", analytics_staff_path)
  end
  
  def announcements_index
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Announcements", announcements_path)
  end
  
  def announcements_new
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Announcements", announcements_path)
    breadcrumb("New Announcement", new_announcement_path)
  end
  
  def assignment_type_weights_index 
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Assignments", assignments_path)
    breadcrumb("Edit My Choices", assignment_type_weights_path)
  end
  
  def assignments_index
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Assignments", assignments_path)
  end

  def assignments_show
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Assignments", assignments_path)
    breadcrumb(objects[:assignment].name, assignment_path(objects[:assignment]))
  end

  def assignments_edit
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Assignments", assignments_path)
    breadcrumb("Editing " + objects[:assignment].name, assignment_path(objects[:assignment]))
  end
  
  def info_dashboard
    breadcrumb("Dashboard", dashboard_path)
  end
  
  def info_grading_status
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Grading Status", grading_status_path)
  end
  
  def info_per_assign
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Assignment Analytics", per_assign_path)
  end
  
  def downloads_index
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Downloads", downloads_path)
  end
  
  def info_top_ten
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Top 10", top_10_path)
  end
  
  def events_index 
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Calendar Events", events_path)
  end
  
  def events_show 
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Calendar Events", events_path)
    breadcrumb(objects[:event].name, event_path(objects[:event]))
  end
  
  def events_edit
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Calendar Events", events_path)
    breadcrumb(objects[:event].name, event_path(objects[:event]))
  end
  
  def rubrics_design
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Assignments", assignments_path)
    breadcrumb(objects[:assignment].name, assignment_path(objects[:assignment]))
    breadcrumb("Design Rubric")
  end
end
