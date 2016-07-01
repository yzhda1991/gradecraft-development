class Courses::ImportController < ApplicationController
  def providers
  end

  def courses
    @provider = params[:provider]

    @courses = []
    canvas = Canvas::API.new ENV['CANVAS_ACCESS_TOKEN']

    canvas.get_data('/courses', enrollment_type: 'teacher') do |courses|
      courses.each do |course|
        @courses << course
      end
    end
  end
end
