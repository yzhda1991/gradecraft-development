class AssignmentsController < ApplicationController
  include AssignmentsHelper
  include SortsPosition

  before_filter :ensure_staff?, except: [:show, :index]

  # rubocop:disable AndOr
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
    render :show, Assignments::Presenter.build({
      assignment: assignment,
      course: current_course,
      team_id: params[:team_id],
      view_context: view_context
      })
  end

  def new
    render :new, Assignments::Presenter.build({
      assignment: current_course.assignments.new,
      course: current_course,
      view_context: view_context
      })
  end

  def edit
    assignment = current_course.assignments.find(params[:id])
    @title = "Editing #{assignment.name}"
    render :edit, Assignments::Presenter.build({
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
      redirect_to assignment_path(assignment), notice: "#{(term_for :assignment).titleize} #{assignment.name} successfully created" and return
    end

    @title = "Create a New #{term_for :assignment}"
    render :new, Assignments::Presenter.build({
      assignment: assignment,
      course: current_course,
      view_context: view_context
      })
  end

  def update
    assignment = current_course.assignments.find(params[:id])
    if assignment.update_attributes(params[:assignment])
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
        @title = "Edit #{term_for :assignment}"
        render :edit, Assignments::Presenter.build({
          assignment: assignment,
          course: current_course,
          view_context: view_context
          })
      end
      format.json { render json: { errors: assignment.errors }, status: 400 }
    end
  end

  def sort
    sort_position_for :assignment
  end

  # GET /assignments/import
  def import
    @title = "Import Assignments"
    @lms_courses = []
    canvas = CanvasApi.new

    canvas.get_data('courses', enrollment_type: 'teacher') do |courses|
      courses.each do |course|
        @lms_courses << course
      end
    end
  end

  # GET /assignments/import
  def import_canvas
    @title = "Import Assignments"
    canvas = CanvasApi.new
    canvas.get_data("courses/#{params[:id]}") do |course|
      @course = course
    end

    @assignments = []
    canvas.get_data("courses/#{params[:id]}/assignments") do |assignments|
      @assignments += assignments
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
end

class CanvasApi
  def initialize
    @url_base = 'https://canvas.instructure.com/api/v1'
    @access_token = ENV['CANVAS_ACCESS_TOKEN']
  end

  def get_data(path = '/', params = {})
    params['access_token'] = @access_token
    next_url = "#{@url_base}/#{path}"
    while next_url
      uri = get_uri(next_url, params)
      resp = Net::HTTP.get_response(uri)
      fail "An error occured #{resp}" unless resp.is_a? Net::HTTPOK
      yield JSON.parse(resp.body)
      next_url = get_next_url resp
    end
  end

  private

  def get_next_url(resp)
    return nil unless resp['Link']
    resp['Link'].split(',').each do |rel|
      url, rel = rel.match(/^<(.*)>; rel="(.*)"$/).captures
      return url if rel == 'next'
    end
    nil
  end

  def get_uri(url, params = {})
    uri = URI(url)

    uri.query = if uri.query.is_a? String
                  "#{uri.query}&#{URI.encode_www_form(params)}"
                else
                  URI.encode_www_form(params)
                end
    uri
  end
end
