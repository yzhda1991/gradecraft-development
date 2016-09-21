class IntegrationsController < ApplicationController
  before_filter :ensure_staff?

  def index
    @course = current_course
    authorize! :read, @course
  end
end
