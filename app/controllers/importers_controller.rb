require "active_lms"
require_relative "../importers/assignment_importers"

class ImportersController < ApplicationController
  before_filter :ensure_staff?

  def index
  end

  def courses
    @provider = params[:importer_id]
    @courses = ActiveLMS::Syllabus.new(@provider,
                                       ENV["#{@provider.upcase}_ACCESS_TOKEN"])
      .courses
  end

  def assignments
    @provider = params[:importer_id]
    importer = ActiveLMS::Syllabus.new(@provider,
                                       ENV["#{@provider.upcase}_ACCESS_TOKEN"])
    @course = importer.course(params[:id])
    @assignments = importer.assignments(params[:id])
    @assignment_types = current_course.assignment_types
  end

  def assignments_import
    @provider = params[:importer_id]

    assignments = ActiveLMS::Syllabus.new(@provider,
                                          ENV["#{@provider.upcase}_ACCESS_TOKEN"])
      .assignments(params[:id], params[:assignment_ids])
    results = CanvasAssignmentImporter.new(assignments).import(current_course,
                                                               params[:assignment_type_id])

    redirect_to assignments_path, notice: "You successfully imported #{results.successful.size} #{@provider.capitalize} #{"assignment".pluralize(results.successful.size)}"
  end
end
