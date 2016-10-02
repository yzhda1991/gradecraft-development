class Students::AssignmentTypeWeightsController < ApplicationController

  before_filter :ensure_staff?

  # GET /students/:id/assignment_type_weights
  # faculty view of student's weights index view
  def index
    render template: "assignment_type_weights/index"
  end
end
