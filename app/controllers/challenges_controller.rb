class ChallengesController < ApplicationController

  before_filter :ensure_staff?, except: [:index, :show, :predictor_data, :predict_points]
  before_filter :ensure_student?, only: [:predict_points]
  before_action :find_challenge, only: [:show, :edit, :update, :destroy]

  def index
    @title = "#{term_for :challenges}"
    @challenges = current_course.challenges
  end

  def show
    @title = @challenge.name
    @teams = current_course.teams
  end

  def new
    @challenge = current_course.challenges.new
    @title = "Create a New #{term_for :challenge}"
  end

  def edit
    @title = "Editing #{@challenge.name}"
  end

  def create
    @challenge = current_course.challenges.create(params[:challenge])

    respond_to do |format|
      if @challenge.save
        format.html { redirect_to @challenge, notice: "Challenge #{@challenge.name} successfully created" }
      else
        format.html { render action: "new" }
      end
    end
  end

  def update
    respond_to do |format|
      if @challenge.update_attributes(params[:challenge])
        format.html { redirect_to challenges_path, notice: "Challenge #{@challenge.name} successfully updated" }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
    @name = "#{@challenge.name}"
    @challenge.destroy

    respond_to do |format|
      format.html { redirect_to challenges_path, notice: "Challenge #{@name} successfully deleted" }
    end
  end

  def predict_points
    @challenge = current_course.challenges.find(params[:challenge_id])
    @challengePrediction = PredictedEarnedChallenge.where(student: current_student, challenge: @challenge).first
    @challengePrediction.points_earned = params[:points_earned]
    @prediction_saved = @challengePrediction.save

    # create a predictor event in mongo to keep track of what happened
    PredictorEventJob.new(data: predictor_event_attrs).enqueue

    respond_to do |format|
      format.json do
        if @prediction_saved
          render json: {id: @challenge.id, points_earned: @challengePrediction.points_earned}
        else
          render json: { errors:  @challengePrediction.errors.full_messages }, status: 400
        end
      end
    end
  end

  def predictor_data
    if current_user.is_student?(current_course)
      @student = current_student
      @update_challenges = true
    elsif params[:id]
      @student = User.find(params[:id])
      @update_challenges = false
    else
      @student = NullStudent.new
      @update_challenges = false
    end
    @challenges = predictor_challenge_data
  end

  private

  def find_challenge
    @challenge = current_course.challenges.includes(:challenge_score_levels).find(params[:id])
  end

  def predictor_event_attrs
    {
      prediction_type: "challenge",
      course_id: current_course.id,
      user_id: current_user.id,
      student_id: current_student.try(:id),
      user_role: current_user.role(current_course),
      challenge_id: params[:challenge_id],
      predicted_points: params[:predicted_score],
      possible_points: @challenge.point_total,
      created_at: Time.now,
      prediction_saved_successfully: @prediction_saved
    }
  end

  def predictor_challenge_data
    challenges = []
    if current_course.challenges.present? && @student.team_for_course(current_course).present? && current_course.add_team_score_to_student
      challenges = current_course.challenges.select(
        :id,
        :name,
        :visible,
        :description,
        :point_total)

      team = @student.team_for_course(current_course)
      @grades = team.challenge_grades

      challenges.each do |challenge|
        prediction = challenge.find_or_create_predicted_earned_challenge(@student.id)
        if current_user.is_student?(current_course)
          challenge.prediction = { id: prediction.id, points_earned: prediction.points_earned }
        else
          challenge.prediction = { id: prediction.id, points_earned: 0 }
        end

        grade = @grades.where(challenge_id: challenge.id).first

        if grade.present? && grade.is_student_visible?
          # point_total is presented on the grade model to mirror the assignment.grade.point_total,
          # which is necessary since assignment.grade.point_total is student specific
          #
          # TODO change score to points_earned on the model,
          #      use points_earned in the front end on challenges and grades
          challenge.grade = { point_total: challenge.point_total, score: grade.score, points_earned: grade.score }
        else
          challenge.grade = { point_total: challenge.point_total, score: nil, points_earned: nil }
        end
      end
    end
    return challenges
  end
end
