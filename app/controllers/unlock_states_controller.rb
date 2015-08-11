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

  def manually_unlock
    session[:return_to] = request.referer
    @unlockable = current_course.assignments.find(params[:assignment_id])
    @student = current_course.students.find(params[:student_id])
    @unlock_state = @unlockable.find_or_create_unlock_state(@student)
    @unlock_state.instructor_unlocked = true
    @unlock_state.save
    redirect_to session[:return_to]
  end
  
end