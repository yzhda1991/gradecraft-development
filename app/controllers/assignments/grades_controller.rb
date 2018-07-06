require_relative "../../services/creates_many_grades"

class Assignments::GradesController < ApplicationController
  before_action :ensure_staff?, except: :self_log
  before_action :ensure_student?, only: :self_log
  before_action :find_assignment, only: [:mass_edit, :mass_update, :self_log, :delete_all]
  before_action :use_current_course, only: [:mass_edit, :mass_update]

  # GET /assignments/:assignment_id/grades/export
  # Sends a CSV file to the user with the current grades for all students
  # in the course for the asisgnment. This has more detail about the student.
  def export
    assignment = current_course.assignments.find(params[:assignment_id])
    respond_to do |format|
      format.csv do
        send_data(GradeExporter.new
          .export_grades_with_detail(assignment, assignment.course.students),
          filename: "#{ assignment.name } Grades - #{ Date.today }.csv")
      end
    end
  end

  # GET /assignments/:assignment_id/grades/export_earned_levels
  def export_earned_levels
    assignment = current_course.assignments.find(params[:assignment_id])
    respond_to do |format|
      format.csv { send_data CriterionGradesExporter.new.export(assignment.course, assignment.rubric), filename: "#{ assignment.name } Rubric Grades - #{ Date.today }.csv" }
    end
  end

  # GET /assignments/:assignment_id/grades
  # View criterion grades for all students in the course for the assignment
  def index
    assignment = current_course.assignments.find(params[:assignment_id])
    # rubocop:disable AndOr
    redirect_to assignment_path(assignment) and return unless assignment.grade_with_rubric?

    # TODO: This should not use an AssignmentPresenter
    render :index, Assignments::Presenter.build({
      assignment: assignment,
      course: current_course,
      team_id: params[:team_id],
      view_context: view_context
      })
  end

  # GET /assignments/:assignment_id/grades/mass_edit
  # Quickly grading a single assignment for all students
  def mass_edit
    redirect_to mass_edit_assignment_groups_grades_path and return if @assignment.has_groups?
  end

  # PUT /assignments/:assignment_id/grades/mass_update
  # Updates all the grades for the students or groups in a course for an assignment
  def mass_update
    filter_params_with_no_grades!
    params[:assignment][:grades_attributes] = params[:assignment][:grades_attributes].each do |key, value|
      value.merge!(instructor_modified: true, complete: true, student_visible: true)
    end
    result = Services::CreatesManyGrades.call @assignment.id, current_user.id, assignment_params[:grades_attributes]

    if result.success?
      if !params[:team_id].blank?
        redirect_to assignment_path(@assignment, team_id: params[:team_id])
      else
        respond_with @assignment
      end
    else
      redirect_to mass_edit_assignment_grades_path(@assignment, team_id: params[:team_id]),
        notice: "Oops! There was an error while saving the grades!"
    end
  end

  # DELETE /assignments/:assignment_id/grades/delete_all
  # Delete grades for a given assignment id
  def delete_all
    if params[:team_id].present?
      team = current_course.teams.find_by(id: params[:team_id])
      students = current_course.students_being_graded_by_team(team).order_by_name
    else
      students = current_course.students_being_graded.order_by_name
    end

    Gradebook.new(@assignment, students).existing_grades.each do |grade|
      grade.destroy
      ScoreRecalculatorJob.new(user_id: grade.student_id, course_id: current_course.id).enqueue
    end

    redirect_to assignment_path(@assignment), flash: {
      success: "Successfully deleted grades for #{ @assignment.name }"
    }
  end

  # PUT /assignments/:assignment_id/grades/self_log
  # Allows students to log grades for student logged assignments
  # either sets raw points to params[:grade][:raw_points]
  # or defaults to point total for assignment
  def self_log
    if @assignment.open? && @assignment.student_logged?
      @grade = Grade.find_or_create(@assignment.id, current_student.id)

      if params[:grade].present? && params[:grade][:raw_points].present?
        @grade.raw_points = params[:grade][:raw_points]
      elsif params[:grade].present? && params[:grade][:pass_fail_status].present?
        @grade.pass_fail_status = params[:grade][:pass_fail_status]
      else
        @grade.raw_points = @assignment.full_points
      end

      @grade.instructor_modified = true
      @grade.complete = true
      @grade.student_visible = true

      if @grade.save
        grade_updater_job = GradeUpdaterJob.new(grade_id: @grade.id)
        grade_updater_job.enqueue

        redirect_to assignments_path,
          notice: "Nice job! Thanks for logging your grade!"
      else
        redirect_to assignments_path,
          notice: "We're sorry, there was an error saving your grade."
      end

    else
      redirect_to dashboard_path,
        notice: "This assignment is not open for self grading."
    end
  end

  private

  def assignment_params
    params.require(:assignment).permit grades_attributes: [:graded_by_id, :graded_at,
      :instructor_modified, :student_id, :raw_points, :pass_fail_status, :id, :complete, :student_visible]
  end

  # Delete params that have no raw_points or pass_fail_status
  # We remove pass_fail_status values of "nil" because we have a "No Change" radio button
  # on the UI, and by default a radio button must have some sort of string value
  def filter_params_with_no_grades!
    params[:assignment][:grades_attributes] = params[:assignment][:grades_attributes].delete_if do |key, value|
      value[:raw_points].blank? && (value[:pass_fail_status].blank? || value[:pass_fail_status] == "nil")
    end
  end

  # Schedule the `GradeUpdater` for all grades provided
  def enqueue_multiple_grade_update_jobs(grade_ids)
    grade_ids.each { |id| GradeUpdaterJob.new(grade_id: id).enqueue }
  end

  def find_assignment
    @assignment = current_course.assignments.find(params[:assignment_id])
  end
end
