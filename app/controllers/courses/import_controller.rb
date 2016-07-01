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
end
