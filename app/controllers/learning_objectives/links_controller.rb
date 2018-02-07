class LearningObjectives::LinksController < ApplicationController
  before_action :ensure_course_uses_objectives?
  before_action :use_current_course

  def index
    @objectives = current_course.learning_objectives.includes(:assignments)
  end
end
