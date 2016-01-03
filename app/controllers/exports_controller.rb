class ExportsController < ApplicationController
  before_filter :ensure_staff?

  def index
    @assignment_exports = current_course
      .assignment_exports
      .order("updated_at DESC")
      .includes(:assignment, :course, :team)
  end
end
