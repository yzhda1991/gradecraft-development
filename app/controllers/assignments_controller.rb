# rubocop:disable AndOr
require "canvas"

class AssignmentsController < ApplicationController
  include AssignmentsHelper

  before_action :ensure_staff?, except: [:show, :index]
  before_action :sanitize_params, only: [:create, :update]
  before_action :use_current_course, only: [:index, :settings, :show, :new, :edit, :grades_review]

  def index
    @assignment_types = @course.assignment_types.ordered.includes(:assignments)
    if current_user_is_student? || current_user_is_observer?
      render :index, Assignments::StudentPresenter.build({
        student: current_student,
        assignment_types: current_course.assignment_types.ordered.includes(:assignments),
        course: current_course,
        view_context: view_context
      })
    end
  end

  # Gives the instructor the chance to quickly check all assignment settings
  # for the whole course
  def settings
    @assignment_types = @course.assignment_types.ordered.includes(:assignments)
  end

  def show
    @assignment = @course.assignments.find_by(id: params[:id])
    redirect_to assignments_path,
      alert: "The #{(term_for :assignment)} could not be found." and return unless @assignment.present?

    mark_assignment_reviewed! @assignment, current_user
    render :show, Assignments::Presenter.build({
      assignment: @assignment,
      course: @course,
      team_id: params[:team_id],
      view_context: view_context
      })
  end

  def new
    render :new, Assignments::Presenter.build({
      assignment: @course.assignments.new,
      course: @course,
      view_context: view_context
      })
  end

  def edit
    @assignment = @course.assignments.find(params[:id])
    render :edit, Assignments::Presenter.build({
      assignment: @assignment,
      course: @course,
      view_context: view_context
      })
  end

  # Duplicate an assignment - important for super repetitive items like
  # attendance and reading reactions
  def copy
    assignment = current_course.assignments.find(params[:id])
    duplicated = assignment.copy
    redirect_to edit_assignment_path(duplicated), notice: "#{(term_for :assignment).titleize} #{duplicated.name} successfully created"
  end

  def create
    assignment = current_course.assignments.new(assignment_params)
    if assignment.save
      redirect_to assignments_path,
        notice: "#{(term_for :assignment).titleize} #{assignment.name} successfully created" \
        and return
    end
    render :new, Assignments::Presenter.build({
      assignment: assignment,
      course: current_course,
      view_context: view_context
      })
  end

  def update
    assignment = current_course.assignments.find(params[:id])
    if assignment.update_attributes assignment_params
      if assignment.grades.present?
        assignment.grades.each do |g|
          g.save
        end
      end
      respond_to do |format|
        format.html do
          redirect_to assignments_path,
            notice: "#{(term_for :assignment).titleize} #{assignment.name } "\
            "successfully updated" and return
        end
        format.json { render json: assignment and return }
      end
    end

    respond_to do |format|
      format.html do
        render :edit, Assignments::Presenter.build({
          assignment: assignment,
          course: current_course,
          view_context: view_context
          })
      end
      format.json { render json: { errors: assignment.errors }, status: 400 }
    end
  end

  def destroy
    assignment = current_course.assignments.find(params[:id])
    assignment.destroy
    redirect_to assignments_url, notice: "#{(term_for :assignment).titleize} #{assignment.name} successfully deleted"
  end

  def export_structure
    course = current_user.courses.find_by(id: params[:id])
    respond_to do |format|
      format.csv { send_data AssignmentExporter.new.export(course), filename: "#{ course.name } #{ (term_for :assignment).titleize } Structure - #{ Date.today }.csv" }
    end
  end

  def grades_review
    @assignment = @course.assignments.find(params[:id])
    if @assignment.grade_with_rubric?
      @criteria = @assignment.rubric.criteria.includes(levels: :level_badges)
      @criterion_grades = @assignment.criterion_grades
    end
    render :grades_review, Assignments::Presenter.build({
      assignment: @assignment,
      course: @course,
      team_id: params[:team_id],
      view_context: view_context
      })
  end

  private

  def sanitize_params
    [:full_points, :threshold_points].each do |points|
      if params[:assignment][points].class == String
        params[:assignment][points].delete!(",").to_i
      end
    end
  end

  def assignment_params
    params.require(:assignment).permit :accepts_attachments, :accepts_links,
      :accepts_submissions, :accepts_submissions_until, :accepts_resubmissions_until,
      :accepts_text, :assignment_type_id, :course_id, :description, :due_at, :grade_scope,
      :include_in_predictor, :include_in_timeline, :include_in_to_do,
      :mass_grade_type, :name, :open_at, :pass_fail, :max_submissions,
      :full_points, :purpose, :release_necessary, :hide_analytics,
      :required, :resubmissions_allowed, :show_description_when_locked,
      :show_purpose_when_locked, :show_name_when_locked, :media, :remove_media,
      :show_points_when_locked, :student_logged, :threshold_points, :use_rubric,
      :visible, :visible_when_locked, :min_group_size, :max_group_size,
      unlock_conditions_attributes: [:id, :unlockable_id, :unlockable_type, :condition_id,
        :condition_type, :condition_state, :condition_value, :condition_date, :_destroy],
      assignment_files_attributes: [:id, file: []],
      assignment_score_levels_attributes: [:id, :name, :points, :_destroy],
      assignment_groups_attributes: [:group_id]
  end
end
