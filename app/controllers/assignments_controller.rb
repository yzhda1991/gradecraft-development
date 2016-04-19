class AssignmentsController < ApplicationController
  include AssignmentsHelper
  include SortsPosition

  before_filter :ensure_staff?, except: [:show, :index, :predictor_data]

  def index
    redirect_to syllabus_path and return if current_user_is_student?
    @title = "#{term_for :assignments}"
    @assignment_types = current_course.assignment_types.includes(:assignments)
  end

  # Gives the instructor the chance to quickly check all assignment settings
  # for the whole course
  def settings
    @title = "Review #{term_for :assignment} Settings"
    @assignment_types = current_course.assignment_types.includes(:assignments)
  end

  def show
    assignment = current_course.assignments.find_by(id: params[:id])
    redirect_to assignments_path,
      alert: "The #{(term_for :assignment)} could not be found." and return unless assignment.present?

    mark_assignment_reviewed! assignment, current_user
    render :show, AssignmentPresenter.build({
      assignment: assignment,
      course: current_course,
      team_id: params[:team_id],
      view_context: view_context
      })
  end

  def new
    render :new, AssignmentPresenter.build({
      assignment: current_course.assignments.new,
      course: current_course,
      view_context: view_context
      })
  end

  def edit
    assignment = current_course.assignments.find(params[:id])
    @title = "Editing #{assignment.name}"
    render :edit, AssignmentPresenter.build({
      assignment: assignment,
      course: current_course,
      view_context: view_context
      })
  end

  # Duplicate an assignment - important for super repetitive items like
  # attendance and reading reactions
  def copy
    assignment = current_course.assignments.find(params[:id])
    duplicated = assignment.copy
    redirect_to assignment_path(duplicated), notice: "#{(term_for :assignment).titleize} #{duplicated.name} successfully created"
  end

  def create
    assignment = current_course.assignments.new(params[:assignment])
    if assignment.save
      set_assignment_weights(assignment)
      redirect_to assignment_path(assignment), notice: "#{(term_for :assignment).titleize} #{assignment.name} successfully created" and return
    end

    @title = "Create a New #{term_for :assignment}"
    render :new, AssignmentPresenter.build({
      assignment: assignment,
      course: current_course,
      view_context: view_context
      })
  end

  def update
    assignment = current_course.assignments.find(params[:id])
    if assignment.update_attributes(params[:assignment])
      set_assignment_weights(assignment)
      redirect_to assignments_path, notice: "#{(term_for :assignment).titleize} #{assignment.name } successfully updated" and return
    end

    @title = "Edit #{term_for :assignment}"
    render :edit, AssignmentPresenter.build({
      assignment: assignment,
      course: current_course,
      view_context: view_context
      })
  end

  def sort
    sort_position_for :assignment
  end

  def update_rubrics
    assignment = current_course.assignments.find params[:id]
    assignment.update_attributes use_rubric: params[:use_rubric]
    redirect_to assignment_path(assignment)
  end

  # current student visible assignment
  def predictor_data
    if current_user_is_student?
      student = current_student
    elsif params[:id]
      student = User.find(params[:id])
    else
      student = NullStudent.new(current_course)
    end
    @assignments = PredictedAssignmentCollectionSerializer.new current_course.assignments, current_user, student
  end

  def destroy
    assignment = current_course.assignments.find(params[:id])
    assignment.destroy
    redirect_to assignments_url, notice: "#{(term_for :assignment).titleize} #{assignment.name} successfully deleted"
  end

  def download_current_grades
    assignment = current_course.assignments.find(params[:id])
    respond_to do |format|
      format.csv { send_data GradeExporter.new.export_grades(assignment, current_course.students) }
    end
  end

  def export_structure
    respond_to do |format|
      format.csv { send_data AssignmentExporter.new.export current_course }
    end
  end

  private

  def set_assignment_weights(assignment)
    return unless assignment.student_weightable?
    assignment.weights = current_course.students.map do |student|
      assignment_weight =
        assignment.weights.where(student: student).first ||
          assignment.weights.new(student: student)
      assignment_weight.weight =
        assignment.assignment_type.weight_for_student(student)
      assignment_weight
    end
    assignment.save
  end
end
