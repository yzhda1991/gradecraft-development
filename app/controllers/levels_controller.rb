class LevelsController < ApplicationController
  before_filter :ensure_staff?

  before_action :find_level, except: [:create]

  respond_to :html, :json

  def create
    @level = Level.create params[:level]
    respond_with @level, layout: false
  end

  def destroy
    @level.destroy
    render nothing: true
  end

  def update
    @level.update_attributes params[:level]
    respond_with @level, layout: false
  end

  private
  
  def find_level
    @level = Level.find params[:id]
  end
end
