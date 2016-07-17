require_relative "../../services/imports_lms_assignments"

class Courses::ImportersController < ApplicationController
  before_filter :ensure_staff?

  # GET /courses/importers
  def index
  end

  # GET /courses/importers/:importer_id/courses
  def courses
    @provider = params[:importer_id]
    @courses = syllabus.courses
  end

  # GET /courses/importers/:importer_id/courses/:id/assignments
  def assignments
    @provider = params[:importer_id]
    @course = syllabus.course(params[:id])
    @assignments = syllabus.assignments(params[:id])
    @assignment_types = current_course.assignment_types
  end

  # POST /courses/importers/:importer_id/courses/:id/assignments
  def assignments_import
    @provider = params[:importer_id]

    @result = Services::ImportsLMSAssignments.import @provider,
      ENV["#{@provider.upcase}_ACCESS_TOKEN"], params[:id], params[:assignment_ids],
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

  # GET /:resource/importers ... etc

  # GET /grades/importers -> displays a list of available importers (csv + canvas)
  # GET /grades/importers/:importer_id/courses -> displays a list of courses available from the provider (canvas only)
  # GET /grades/importers/:importer_id/courses/:id/assignments -> displays a list of assignments for the course from the provider (canvas only)
  # POST /importers/:importer_id/assignments/:id/grades

  private

  def syllabus
    @syllabus ||= ActiveLMS::Syllabus.new(@provider,
                                          ENV["#{@provider.upcase}_ACCESS_TOKEN"])
  end
end
