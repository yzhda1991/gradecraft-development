class ChallengesController < ApplicationController

  before_action :ensure_staff?,
    except: [:index, :show, :predict_points]
  before_action :ensure_student?, only: [:predict_points]
  before_action :find_challenge, only: [:show, :edit, :update, :destroy]
  before_action :use_current_course

  def index
    @challenges = current_course.challenges
  end

  def show
    @teams = current_course.teams
  end

  def new
    @challenge = current_course.challenges.new
  end

  def edit
  end

  def create
    @challenge = current_course.challenges.create(challenge_params)

    if @challenge.save
      respond_with @challenge, location: challenges_path
    else
      render action: "new"
    end
  end

  def update
    if @challenge.update_attributes(challenge_params)
      respond_with @challenge, location: challenges_path
    else
      render action: "edit"
    end
  end

  def destroy
    @challenge.destroy
    respond_with @challenge, location: challenges_path
  end

  private

  def challenge_params
    params.require(:challenge).permit :name, :description, :visible, :full_points,
      :due_at, :open_at, :course, :team, :challenge,
      :challenge_grades_attributes,  :media, :remove_media,
      challenge_score_levels_attributes: [:id, :name, :points, :_destroy],
      challenge_files_attributes: [:id, file: []]
  end

  def find_challenge
    @challenge = current_course.challenges.includes(:challenge_score_levels).find(params[:id])
  end

  def flash_interpolation_options
    { resource_name: @challenge.name }
  end
end
