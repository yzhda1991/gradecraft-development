class Grades::ImportersController < ApplicationController
  before_filter :ensure_staff?

  # GET /grades/importers
  def index
    @assignment = Assignment.find params[:assignment_id]
  end
end
