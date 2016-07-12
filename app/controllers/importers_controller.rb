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
end
