class BreadcrumbTrail < Croutons::BreadcrumbTrail
  
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
    assignments_index
    breadcrumb(objects[:assignment].name, assignment_path(objects[:assignment]))
  end
  
  def info_dashboard
    breadcrumb("Dashboard", dashboard_path)
  end
end
