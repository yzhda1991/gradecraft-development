class API::StudentsController < ApplicationController
  before_action :ensure_staff?

  # PUT api/students
  def index
    students = current_course.students.map do |u|
      { name: u.name, id: u.id }
    end
    render json: MultiJson.dump(students)
  end
end


