class API::DashboardController < ApplicationController
  
  # GET /api/dashboard/due_this_week
  def due_this_week
    @presenter = Info::DashboardCoursePlannerPresenter.new({
      student: current_student,
      assignments: current_course.assignments.chronological,
      course: current_course,
      view_context: view_context
    })
  end
end
