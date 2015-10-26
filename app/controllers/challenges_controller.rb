class ChallengesController < ApplicationController

  before_filter :ensure_staff?, :except=>[:index, :show, :student_predictor_data, :predict_points]
  before_filter :ensure_student?, only: [:predict_points]

  def index
    @title = "#{term_for :challenges}"
    @challenges = current_course.challenges
  end

  def show
    @challenge = current_course.challenges.find(params[:id])
    @title = @challenge.name
    @teams = current_course.teams
  end

  def new
    @challenge = current_course.challenges.new
    @title = "Create a New #{term_for :challenge}"
  end

  def edit
    @challenge = current_course.challenges.find(params[:id])
    @title = "Editing #{@challenge.name}"
  end

  def create
    if params[:challenge][:challenge_files_attributes].present?
      @challenge_files = params[:challenge][:challenge_files_attributes]["0"]["file"]
      params[:challenge].delete :challenge_files_attributes
    end

    @challenge = current_course.challenges.create(params[:challenge])

    if @challenge_files
      @challenge_files.each do |cf|
        @challenge.challenge_files.new(file: cf, filename: cf.original_filename[0..49])
      end
    end

    respond_to do |format|
      if @challenge.save
        format.html { redirect_to @challenge, notice: "Challenge #{@challenge.name} successfully created" }
        format.json { render json: @challenge, status: :created, location: @challenge }
      else
        # TODO: refactor, see submissions_controller
        @title = "Create a New #{term_for :challenge}"
        format.html { render action: "new" }
        format.json { render json: @challenge.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    if params[:challenge][:challenge_files_attributes].present?
      @challenge_files = params[:challenge][:challenge_files_attributes]["0"]["file"]
      params[:challenge].delete :challenge_files_attributes
    end

    @challenge = current_course.challenges.includes(:challenge_score_levels).find(params[:id])

    if @challenge_files
      @challenge_files.each do |cf|
        @challenge.challenge_files.new(file: cf, filename: cf.original_filename[0..49])
      end
    end

    respond_to do |format|
      if @challenge.update_attributes(params[:challenge])
        format.html { redirect_to challenges_path, notice: "Challenge #{@challenge.name} successfully updated" }
        format.json { head :ok }
      else
        # TODO: refactor, see submissions_controller
        @title = "Editing #{@challenge.name}"
        format.html { render action: "edit" }
        format.json { render json: @challenge.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @challenge = current_course.challenges.find(params[:id])
    @name = "#{@challenge.name}"
    @challenge.destroy

    respond_to do |format|
      format.html { redirect_to challenges_path, notice: "Challenge #{@name} successfully deleted" }
      format.json { head :ok }
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
          render :json => {id: @challenge.id, points_earned: @challengePrediction.points_earned}
        else
          render :json => { errors:  @challengePrediction.errors.full_messages }, :status => 400
        end
      end
    end
  end

  private

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

  public

  def student_predictor_data
    if current_user.is_student?(current_course)
      @student = current_student
    elsif params[:id]
      @student = User.find(params[:id])
    else
      @student = NullStudent.new
    end

    @challenges = []
    if current_course.challenges.present? && @student.team_for_course(current_course).present? && current_course.add_team_score_to_student
      @challenges = current_course.challenges

      @challenges.each do |challenge|
        challenge.student_predicted_earned_challenge = challenge.find_or_create_predicted_earned_challenge(@student)
      end

      team = @student.team_for_course(current_course)

      @grades = team.challenge_grades

      @challenges.each do |challenge|
        @grades.where(:challenge_id => challenge.id).first.tap do |grade|

          if grade.nil?
            grade = ChallengeGrade.create(:challenge => challenge, :team => team)
          end

          challenge.current_team_grade = grade
        end
      end
    end
  end
end
