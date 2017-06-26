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

  # Returns all grade ids for the current course; for fetching by batch
  # GET api/gradebook/grade_ids
  def grade_ids
    render json: MultiJson.dump(current_course.grades.pluck(:id))
  end

  # Returns gradebook data for the grades in the current course
  # Optionally returns a subset of grades if provided an array of grade ids
  # GET api/gradebook/grades
  def grades
    @grades = current_course.grades

    if params[:grade_ids].present?
      @grades = @grades.where(id: params[:grade_ids])
    end
  end
end
