
class API::LevelsController < ApplicationController
  before_filter :ensure_staff?


  # PUT api/level/:id
  def update
    level = Level.find(params[:id])
    level.criterion.remove_expectations if updating_meets_expectations?

    if level.update_attributes(level_params)
      render json: { message: "level successfully updated", success: true }
    else
      render json: {
        errors: [{ detail: "failed to update level" }], success: false
        },
        status: 500
    end
  end

  private

  def updating_meets_expectations?
    params[:level][:meets_expectations] == true
  end

  def level_params
     params.require(:level).permit(:meets_expectations)
   end
end


