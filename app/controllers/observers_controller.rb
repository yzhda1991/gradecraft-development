class ObserversController < ApplicationController
  before_action :ensure_staff?

  def index
    @observers = current_course.observers
  end
end
