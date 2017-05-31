class API::Assignments::GradesController < ApplicationController
  before_action :ensure_staff?

  # GET /api/assignments/:assignment_id/grades
  def show
    @assignment = Assignment.includes(grades: :student).find params[:assignment_id]

    if params[:team_id].present?
      team = current_course.teams.find params[:team_id]
      students = current_course.students_being_graded_by_team(team).order_by_name
    else
      students = current_course.students_being_graded.order_by_name
    end
    @grades = Gradebook.new(@assignment, students).grades
  end
end
