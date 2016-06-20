class AssignmentTypeWeightsController < ApplicationController

  before_filter :ensure_student?

  # GET /assignment_type_weights
  def index
    @title =
      "Editing My #{term_for :weight} Choices" if current_user_is_student?
  end
end
