require_relative "../services/imports_lms_assignments"

class ImportersController < ApplicationController
  before_filter :ensure_staff?

  # GET /importers
  def index
  end

  # GET /importers/:importer_id/courses
  def courses
    @provider = params[:importer_id]
    @courses = syllabus.courses
  end

  # GET /importers/:importer_id/courses/:id/assignments
  def assignments
    @provider = params[:importer_id]
    @course = syllabus.course(params[:id])
    @assignments = syllabus.assignments(params[:id])
    @assignment_types = current_course.assignment_types
  end

  # POST /importers/:importer_id/courses/:id/assignments
  def assignments_import
    @provider = params[:importer_id]

    @result = Services::ImportsLMSAssignments.import @provider,
      ENV["#{@provider.upcase}_ACCESS_TOKEN"], params[:id], params[:assignment_ids],
      current_course, params[:assignment_type_id]

    render :assignments_import_results
  end

  private

  def syllabus
    @syllabus ||= ActiveLMS::Syllabus.new(@provider,
                                          ENV["#{@provider.upcase}_ACCESS_TOKEN"])
  end
end
