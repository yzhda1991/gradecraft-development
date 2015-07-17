class UnlockStatesController < ApplicationController

  #Unlock States are used to ...

  before_filter :ensure_staff?

  def create
    @unlock_state = current_course.unlock_state.new(params[:unlock_condition])
    @unlock_condition.save
  end

  def update
    @unlock_state = current_course.unlock_states.find(params[:id])
    @unlock_state.update_attributes(params[:unlock_condition])
    respond_with @unlock_state
  end

  def destroy
    @unlock_state = current_course.unlock_state.find(params[:id])
    @unlock_state.destroy
  end
  
end