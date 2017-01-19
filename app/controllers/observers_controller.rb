class ObserversController < ApplicationController
  respond_to :html, :json

  before_action :ensure_staff?

  def index
    @observers = current_course.observers
  end
end
