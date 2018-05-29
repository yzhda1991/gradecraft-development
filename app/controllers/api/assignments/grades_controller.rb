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

  # /api/assignments/grades/release
  def release
    grades = current_course.grades.where(id: params[:grade_ids])
    return head :not_found if grades.empty?

    release_grades(grades)
    head :ok
  end

  # /api/assignments/:assignment_id/grades/release
  # Optional: params[:grade_ids]
  def release_for_assignment
    assignment = current_course.assignments.find params[:assignment_id]
    grades = assignment.grades
    grades = grades.where(id: params[:grade_ids]) if params[:grade_ids].present?
    return head :not_found if grades.empty?

    release_grades(grades)
    head :ok
  end

  private

  def release_grades(grades)
    grades.update instructor_modified: true, complete: true, student_visible: true
    enqueue_grade_update_jobs grades.pluck(:id)
  end

  def enqueue_grade_update_jobs(grade_ids)
    grade_ids.each { |id| GradeUpdaterJob.new(grade_id: id).enqueue }
  end
end
