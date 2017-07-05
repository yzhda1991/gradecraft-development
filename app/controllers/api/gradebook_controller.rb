class API::GradebookController < ApplicationController
  before_action :ensure_staff?

  # Flattens all ordered assignments into an array of attribute hashes
  # GET api/gradebook/assignments
  def assignments
    @assignments = []

    current_course.assignment_types.ordered.each do |type|
      type.assignments.ordered.find_each(batch_size: 50) do |assignment|
        @assignments << {
          id: assignment.id,
          name: assignment.name
        }
      end
    end
  end

  # Returns all student ids for the current course; for fetching by batch
  # GET api/gradebook/student_ids
  def student_ids
    render json: MultiJson.dump(current_course.students.pluck(:id))
  end

  # Returns gradebook data for the students in the current course
  # Optionally returns a subset of students if provided an array of student ids
  # GET api/gradebook/students
  def students
    @students = current_course.students
    @students = @students.where(id: params[:student_ids]) if params[:student_ids].present?
  end
end
