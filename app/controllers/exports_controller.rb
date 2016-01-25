class ExportsController < ApplicationController
  before_filter :ensure_staff?

  def index
    @submissions_exports = current_course
      .submissions_exports
      .order("updated_at DESC")
      .includes(:assignment, :course, :team)
  end
end
