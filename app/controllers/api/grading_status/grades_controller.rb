class API::GradingStatus::GradesController < ApplicationController
  before_action :ensure_staff?
  before_action :find_grades

  def in_progress
    @grades = @grades.in_progress
    render :"api/grading_status/grades/index", status: :ok
  end

  def ready_for_release
    @grades = @grades
      .includes(:assignment, :student, :group)
      .ready_for_release
    render :"api/grading_status/grades/index", status: :ok
  end

  private

  def find_grades
    @grades = current_course
      .grades
      .for_active_students
      .instructor_modified
  end
end
