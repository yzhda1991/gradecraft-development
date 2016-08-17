require_relative "../../services/imports_lms_assignments"

class Assignments::ImportersController < ApplicationController
  include OAuthProvider

  before_filter :ensure_staff?
  before_filter except: :index do |controller|
    controller.set_unauthorized_path assignments_importers_path
  end
  before_filter :require_authorization, except: :index

  # GET /assignments/importers
  def index
  end

  # GET /assignments/importers/:importer_provider_id/courses
  def courses
    @provider_name = params[:importer_provider_id]
    @courses = syllabus.courses
  end

  # GET /assignments/importers/:importer_provider_id/courses/:id/assignments
  def assignments
    @provider_name = params[:importer_provider_id]
    @course = syllabus.course(params[:id])
    @assignments = syllabus.assignments(params[:id])
    @assignment_types = current_course.assignment_types
  end

  # POST /assignments/importers/:importer_provider_id/courses/:id/assignments
  def assignments_import
    @provider_name = params[:importer_provider_id]

    @result = Services::ImportsLMSAssignments.import @provider_name,
      authorization(@provider_name).access_token, params[:id], params[:assignment_ids],
      current_course, params[:assignment_type_id]

    if @result.success?
      render :assignments_import_results
    else
      @course = syllabus.course(params[:id])
      @assignments = syllabus.assignments(params[:id])
      @assignment_types = current_course.assignment_types

      render :assignments, alert: @result.message
    end
  end

  private

  def syllabus
    @syllabus ||= ActiveLMS::Syllabus.new \
      @provider_name,
      authorization(@provider_name).access_token
  end
end
