#spec/controllers/challenges_controller_spec.rb
require 'spec_helper'

describe ChallengesController do

	context "as professor" do

    before(:all) do
      clean_models
      @course = create(:course, add_team_score_to_student: true)
      @professor = create(:user)
      @professor.courses << @course
      @membership = CourseMembership.where(user: @professor, course: @course).first.update(role: "professor")
      @challenge = create(:challenge, course: @course)
      @course.challenges << @challenge
      @challenges = @course.challenges
      @student = create(:user)
      @student.courses << @course
      @team = create(:team, course: @course)
      @team.students << @student
      @teams = @course.teams
    end

    before do
      login_user(@professor)
      session[:course_id] = @course.id
      allow(Resque).to receive(:enqueue).and_return(true)
    end

		describe "GET index" do
      it "returns challenges for the current course" do
        get :index
        expect(assigns(:title)).to eq("team Challenges")
        expect(assigns(:challenges)).to eq(@challenges)
        expect(response).to render_template(:index)
      end
    end

		describe "GET show" do
      it "returns the challenge show page" do
        get :show, :id => @challenge.id
        expect(assigns(:title)).to eq(@challenge.name)
        expect(assigns(:challenge)).to eq(@challenge)
        expect(response).to render_template(:show)
      end
    end

		describe "GET new" do
      it "assigns title and challenge" do
        get :new
        expect(assigns(:title)).to eq("Create a New team Challenge")
        expect(assigns(:challenge)).to be_a_new(Challenge)
        expect(response).to render_template(:new)
      end
    end

    describe "GET edit" do
      it "assigns the challenge and title" do
        get :edit, :id => @challenge.id
        expect(assigns(:title)).to eq("Editing #{@challenge.name}")
        expect(assigns(:challenge)).to eq(@challenge)
        expect(response).to render_template(:edit)
      end
    end

		describe "POST create" do
      it "creates the challenge with valid attributes"  do
        params = attributes_for(:challenge)
        params[:challenge_id] = @challenge
        expect{ post :create, :challenge => params }.to change(Challenge,:count).by(1)
      end

      it "manages file uploads" do
        Challenge.delete_all
        params = attributes_for(:challenge)
        params[:challenge_id] = @challenge
        params.merge! :challenge_files_attributes => {"0" => {"file" => [fixture_file('test_file.txt', 'txt')]}}
        post :create, :challenge => params
        challenge = Challenge.where(name: params[:name]).last
        expect expect(challenge.challenge_files.count).to eq(1)
      end

      it "redirects to new from with invalid attributes" do
        expect{ post :create, challenge: attributes_for(:challenge, name: nil) }.to_not change(Challenge,:count)
      end
    end

		describe "POST update" do

      before do
        @challenge_2 = create(:challenge, course: @course)
      end

      after do
        @challenge_2.destroy
      end

      it "updates the challenge" do
        params = { name: "new name" }
        post :update, id: @challenge_2.id, :challenge => params
        @challenge_2.reload
        expect(response).to redirect_to(challenges_path)
        expect(@challenge_2.name).to eq("new name")
      end

      it "manages file uploads" do
        params = {:challenge_files_attributes => {"0" => {"file" => [fixture_file('test_file.txt', 'txt')]}}}
        post :update, id: @challenge_2.id, :challenge => params
        expect expect(@challenge_2.challenge_files.count).to eq(1)
      end
    end

		describe "GET destroy" do

      before do
        @challenge_2 = create(:challenge, course: @course)
      end

      it "destroys the challenge" do
        expect{ get :destroy, :id => @challenge_2 }.to change(Challenge,:count).by(-1)
      end
    end

    describe "GET predictor_data" do

      before do
        allow(controller).to receive(:current_course).and_return(@course)
        allow(controller).to receive(:current_user).and_return(@professor)
      end

      it "adds the prediction data to the challenge model with a zero points prediction" do
        prediction = create(:predicted_earned_challenge, challenge: @challenge, student: @student)
        get :predictor_data, format: :json, :id => @student.id
        expect(assigns(:challenges)[0].prediction).to eq({ id: prediction.id, points_earned: 0 })
      end

      it "adds visible grades to the challenge data" do
        grade = create(:graded_challenge_grade, challenge: @challenge, team: @team)
        get :predictor_data, format: :json, :id => @student.id
        expect(assigns(:challenges)[0].grade).to eq({ point_total: grade.point_total, score: grade.score, points_earned: grade.score })
      end

      it "adds grades as nil when not visible to student" do
        @challenge.update(release_necessary: true)
        grade = create(:grades_not_released_challenge_grade, challenge: @challenge, team: @team)
        get :predictor_data, format: :json, :id => @student.id
        expect(assigns(:challenges)[0].grade).to eq({ point_total: grade.point_total, score: nil, points_earned: nil })
      end

      context "with a student id" do
        it "assigns the challenges with no call to update" do
          get :predictor_data, format: :json, :id => @student.id
          expect(assigns(:student)).to eq(@student)
          expect(assigns(:challenges)[0].attributes.length).to eq(predictor_challenge_attributes.length)
          predictor_challenge_attributes do |attr|
            expect(assigns(:challenges)[0][attr]).to eq(@challenge[attr])
          end
          expect(assigns(:update_challenges)).to be_falsy
          expect(response).to render_template(:predictor_data)
        end
      end

      context "with no student" do
        it "assigns student as null student and no call to update" do
          get :predictor_data, format: :json
          expect(assigns(:student).class).to eq(NullStudent)
          expect(assigns(:update_challenges)).to be_falsy
        end
      end
    end
	end

	context "as student" do

    describe "accessible routes" do

      before(:all) do
        clean_models
        @course = create(:course, add_team_score_to_student: true)
        @challenge = create(:challenge, course: @course)
        @course.challenges << @challenge
        @challenges = @course.challenges
        @student = create(:user)
        @student.courses << @course
        @team = create(:team, course: @course)
        @team.students << @student
        @teams = @course.teams
      end

      before do
        login_user(@student)
        session[:course_id] = @course.id
        allow(Resque).to receive(:enqueue).and_return(true)
        allow(controller).to receive(:current_course).and_return(@course)
        allow(controller).to receive(:current_user).and_return(@student)
        allow(controller).to receive(:current_student).and_return(@student)
      end

      describe "POST predict_points" do
        it "updates the predicted points for a challenge" do
          predicted_earned_challenge = create(:predicted_earned_challenge, challenge: @challenge, student: @student)
          predicted_points = (@challenge.point_total * 0.75).to_i
          post :predict_points, challenge_id: @challenge.id, points_earned: predicted_points, format: :json
          expect(PredictedEarnedChallenge.where(student: @student, challenge: @challenge).first.points_earned).to eq(predicted_points)
          expect(JSON.parse(response.body)).to eq({"id" => @challenge.id, "points_earned" => predicted_points})
        end
      end

      describe "GET predictor_data" do
        it "assigns the challenges with call to update" do
          get :predictor_data, format: :json, :id => @student.id
          expect(assigns(:student)).to eq(@student)
          expect(assigns(:challenges)[0].attributes.length).to eq(predictor_challenge_attributes.length)
          predictor_challenge_attributes do |attr|
            expect(assigns(:challenges)[0][attr]).to eq(@challenge[attr])
          end
          expect(assigns(:update_challenges)).to be_truthy
          expect(response).to render_template(:predictor_data)
        end

        it "adds the prediction data to the challenge data" do
          prediction = create(:predicted_earned_challenge, challenge: @challenge, student: @student)
          get :predictor_data, format: :json, :id => @student.id
          expect(assigns(:challenges)[0].prediction).to eq({ id: prediction.id, points_earned: prediction.points_earned })
        end

        it "adds visible grades to the challenge data" do
          grade = create(:graded_challenge_grade, challenge: @challenge, team: @team)
          get :predictor_data, format: :json, :id => @student.id
          expect(assigns(:challenges)[0].grade).to eq({ point_total: grade.point_total, score: grade.score, points_earned: grade.score })
        end

        it "adds grades as nil when not visible to student" do
          @challenge.update(release_necessary: true)
          grade = create(:grades_not_released_challenge_grade, challenge: @challenge, team: @team)
          get :predictor_data, format: :json, :id => @student.id
          expect(assigns(:challenges)[0].grade).to eq({ point_total: grade.point_total, score: nil, points_earned: nil })
        end
      end

    end

		describe "protected routes" do
      [
        :index,
        :new,
        :create

      ].each do |route|
          it "#{route} redirects to root" do
            expect(get route).to redirect_to(:root)
          end
        end
    end

    describe "protected routes requiring id in params" do
      [
        :edit,
        :show,
        :update,
        :destroy
      ].each do |route|
        it "#{route} redirects to root" do
          expect(get route, {:id => "1"}).to redirect_to(:root)
        end
      end
    end
	end

# helper methods:

  def predictor_challenge_attributes
    [
      :id,
      :name,
      :description,
      :point_total,
      :visible
    ]
  end
end
