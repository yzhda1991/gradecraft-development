require "active_lms"
require_relative "../importers/assignment_importers"

class ImportersController < ApplicationController
  before_filter :ensure_staff?

  def index
  end

  def courses
    @provider = params[:importer_id]
    @courses = syllabus.courses
  end

  def assignments
    @provider = params[:importer_id]
    @course = syllabus.course(params[:id])
    @assignments = syllabus.assignments(params[:id])
    @assignment_types = current_course.assignment_types
  end

  def assignments_import
    @provider = params[:importer_id]

    assignments = syllabus.assignments(params[:id], params[:assignment_ids])
    @result = CanvasAssignmentImporter.new(assignments).import current_course,
                                                               params[:assignment_type_id]
    render :assignments_import_results
  end

  private

  def syllabus
    @syllabus ||= ActiveLMS::Syllabus.new(@provider,
                                          ENV["#{@provider.upcase}_ACCESS_TOKEN"])
  end
end
