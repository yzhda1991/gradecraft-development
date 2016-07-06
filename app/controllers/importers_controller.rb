require "lms_importer"

class ImportersController < ApplicationController
  before_filter :ensure_staff?

  def index
  end

  def courses
    @provider = params[:importer_id]
    @courses = LMSImporter::CourseImporter.new(@provider,
                                               ENV["#{@provider.upcase}_ACCESS_TOKEN"])
      .courses
  end

  def assignments
    @provider = params[:importer_id]
    importer = LMSImporter::CourseImporter.new(@provider,
                                               ENV["#{@provider.upcase}_ACCESS_TOKEN"])
    @course = importer.course(params[:id])
    @assignments = importer.assignments(params[:id])
  end

  def assignments_import
    @provider = params[:provider]
    assignment_ids = params[:assignment_ids]

    imported = LMSImporter::CourseImporter.new(@provider,
                                               ENV["#{@provider.upcase}_ACCESS_TOKEN"])
      .import_assignments(assignment_ids, current_course)

    redirect_to assignments_path, notice: "You successfully imported #{imported.size} #{@provider.capitalize} #{"assignment".pluralize(imported.size)}"
  end
end
