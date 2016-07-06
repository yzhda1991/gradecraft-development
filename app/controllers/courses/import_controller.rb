require "lms_importer"

class Courses::ImportController < ApplicationController
  before_filter :ensure_staff?

  def providers
  end

  def courses
    @provider = params[:provider]
    @courses = LMSImporter::CourseImporter.new(@provider,
                                               ENV["#{@provider.upcase}_ACCESS_TOKEN"])
      .courses
  end

  def assignments
    @provider = params[:provider]
    importer = LMSImporter::CourseImporter.new(@provider,
                                               ENV["#{@provider.upcase}_ACCESS_TOKEN"])
    @course = importer.course(params[:id])
    @assignments = importer.assignments(params[:id])
  end
end
