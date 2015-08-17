class UnlockConditionsController < ApplicationController

  #Unlock Conditions are used to ...

  before_filter :ensure_staff?

  def create
    @unlock_condition = current_course.unlock_condition.new(params[:unlock_condition])
    @unlock_condition.save
  end

  def update
    @unlock_condition = current_course.unlock_conditions.find(params[:id])
    @unlock_condition.update_attributes(params[:unlock_condition])
    respond_with @unlock_condition
  end

  def destroy
    @unlock_condition = current_course.unlock_conditions.find(params[:id])
    @unlock_condition.destroy
  end
  
end