require "lms_importer"

class Courses::ImportController < ApplicationController
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
    @assignments = LMSImporter::CourseImporter.new(@provider,
                                               ENV["#{@provider.upcase}_ACCESS_TOKEN"])
      .assignments(params[:id])
  end
end
