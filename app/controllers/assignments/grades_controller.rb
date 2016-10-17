require_relative "../../services/creates_many_grades"

class Assignments::GradesController < ApplicationController
  before_filter :ensure_staff?, except: :self_log
  before_filter :ensure_student?, only: :self_log
  before_filter :save_referer, only: :edit_status
  before_action :find_assignment, only: [:edit_status, :mass_edit, :mass_update, :self_log, :delete_all]
  before_action :find_grades_for_assignment, only: [:mass_edit, :delete_all]

  # GET /assignments/:assignment_id/grades/edit_status
  # For changing the status of a group of grades passed in grade_ids
  # ("In Progress" => "Graded", or "Graded" => "Released")
  def edit_status
    @grades = @assignment.grades.find(params[:grade_ids])
  end

  # PUT /assignments/:assignment_id/grades/update_status
  def update_status
    assignment = current_course.assignments.find(params[:assignment_id])
    grades = assignment.grades.find(params[:grade_ids])
    status = params[:grade][:status]

    grade_ids = grades.collect do |grade|
      grade.update(status: status)
      EarnedBadge.where(grade_id: grade.id).each(&:save)
      grade.id
    end

    enqueue_multiple_grade_update_jobs(grade_ids)

    if session[:return_to].present?
      redirect_to session[:return_to], notice: "Grades were successfully updated!"
    else
      redirect_to assignment, notice: "Grades were successfully updated!"
    end
  end

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

  # GET /assignments/:assignment_id/grades/export/mass_edit
  # Quickly grading a single assignment for all students
  def mass_edit
    @assignment = current_course.assignments.find(params[:assignment_id])
    if @assignment.has_groups?
      redirect_to mass_edit_assignment_groups_grades_path and return
    end

    @assignment_type = @assignment.assignment_type
    @assignment_score_levels = @assignment.assignment_score_levels.order_by_points

    if params[:team_id].present?
      @team = current_course.teams.find_by(id: params[:team_id])
      @students = current_course.students_being_graded_by_team(@team)
    else
      @students = current_course.students_being_graded
    end

    @grades = Grade.find_or_create_grades(@assignment.id, @students.pluck(:id))
    @grades = @grades.sort_by { |grade| [ grade.student.last_name, grade.student.first_name ] }
  end

  # PUT /assignments/:assignment_id/grades/mass_update
  # Updates all the grades for the students or groups in a course for an assignment
  def mass_update
    filter_params_with_raw_points! :grades_attributes
    @assignment = current_course.assignments.find(params[:assignment_id])
    result = Services::CreatesManyGrades.create @assignment.id, current_user.id, assignment_params[:grades_attributes]

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
    @grades.each do |grade|
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
      else
        @grade.raw_points = @assignment.full_points
      end

      @grade.instructor_modified = true
      @grade.status = "Graded"

      if @grade.save
        # @mz TODO: add specs
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
                                                           :instructor_modified, :student_id,
                                                           :raw_points, :status, :pass_fail_status,
                                                           :id]
  end

  def filter_params_with_raw_points!(attribute_name)
    params[:assignment][attribute_name] = params[:assignment][attribute_name].delete_if do |key, value|
      value[:raw_points].nil? || value[:raw_points].empty?
    end
  end

  # Schedule the `GradeUpdater` for all grades provided
  def enqueue_multiple_grade_update_jobs(grade_ids)
    grade_ids.each { |id| GradeUpdaterJob.new(grade_id: id).enqueue }
  end

  # Retrieve all grades for an assignment if it has a score
  def mass_update_grade_ids
    @assignment.grades.inject([]) do |memo, grade|
      scored_changed = grade.previous_changes[:raw_points].present?
      if scored_changed && grade.graded_or_released?
        memo << grade.id
      end
      memo
    end
  end

  def find_assignment
    @assignment = current_course.assignments.find(params[:assignment_id])
  end

  def find_grades_for_assignment
    if params[:team_id].present?
      @team = current_course.teams.find_by(id: params[:team_id])
      @students = current_course.students_being_graded_by_team(@team)
    else
      @students = current_course.students_being_graded
    end
    @grades = Grade.find_or_create_grades(@assignment.id, @students.pluck(:id))
  end

  def assign_graded_at_date(params)
    params.each do |index, value|
      value.merge!(graded_at: DateTime.now)
    end
  end

  def redirect_on_mass_update_success
    if !params[:team_id].blank?
      redirect_to assignment_path(@assignment, team_id: params[:team_id])
    else
      respond_with @assignment
    end
  end

  def redirect_on_mass_update_failure
    redirect_to mass_edit_assignment_grades_path(@assignment, team_id: params[:team_id]),
      notice: "Oops! There was an error while saving the grades!"
  end
end
