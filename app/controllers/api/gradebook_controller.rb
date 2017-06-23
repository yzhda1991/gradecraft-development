class API::GradebookController < ApplicationController
  before_action :ensure_staff?

  # Retusn all assignment names sorted by assignment type order, assignment order
  # GET api/gradebook/assignment_names
  def assignment_names

  end
end
