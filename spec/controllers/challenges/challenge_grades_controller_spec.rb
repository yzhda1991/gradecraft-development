require "rails_spec_helper"

describe Challenges::ChallengeGradesController do

  before(:all) do
    @course = create(:course)
    @student = create(:user)
    @student.courses << @course
    @team = create(:team, course: @course)
    @team.students << @student
    @challenge = create(:challenge, course: @course)
  end

  before(:each) do
    session[:course_id] = @course.id
    allow(Resque).to receive(:enqueue).and_return(true)
  end

  context "as professor" do
    before(:all) do
      @professor = create(:user)
      CourseMembership.create user: @professor, course: @course, role: "professor"
    end

    before(:each) do
      @challenge_grade = create(:challenge_grade, team: @team, challenge: @challenge)
      login_user(@professor)
    end

    describe "GET mass_edit" do
      it "assigns params" do
        get :mass_edit, challenge_id: @challenge.id
        expect(assigns(:title)).to eq("Quick Grade #{@challenge.name}")
        expect(response).to render_template(:mass_edit)
      end
    end

    describe "POST mass_update" do
      it "updates the challenge grades for the specific challenge" do
        challenge_grades_attributes = { "#{@challenge.challenge_grades.index(@challenge_grade)}" =>
          { team_id: @team.id, score: 1000, status: "Released",
            id: @challenge_grade.id
          }
        }
        put :mass_update, challenge_id: @challenge.id,
          challenge: { challenge_grades_attributes: challenge_grades_attributes }
        expect(@challenge_grade.reload.score).to eq 1000
      end

      it "redirects to the mass_edit form if attributes are invalid" do
        challenge_grades_attributes = { "#{@challenge.challenge_grades.index(@challenge_grade)}" =>
          { team_id: nil, score: 1000, status: "Released",
            id: @challenge_grade.id
          }
        }
        put :mass_update, challenge_id: @challenge.id,
          challenge: { challenge_grades_attributes: challenge_grades_attributes }
        expect(response).to render_template(:mass_edit)
      end
    end

    describe "GET edit_status" do
      it "displays the edit_status page" do
        get :edit_status, { challenge_id: @challenge.id, challenge_grade_ids: [ @challenge_grade.id ] }
        expect(assigns(:title)).to eq("#{@challenge.name} Grade Statuses")
        expect(response).to render_template(:edit_status)
      end
    end

    describe "POST update_status" do
      it "updates the status of multiple challenge grades" do
        post :update_status, { challenge_id: @challenge.id, challenge_grade_ids: [ @challenge_grade.id ], challenge_grade: {"status"=> "Released"}}
        expect(response).to redirect_to challenge_path(@challenge)
      end
    end
  end

  context "as student" do
    describe "protected routes requiring id in params" do
    [
      :mass_edit,
      :mass_update,
      :edit_status,
      :update_status
    ].each do |route|
        it "#{route} redirects to root" do
          expect(get route, {challenge_id: 2, id: "1"}).to redirect_to(:root)
        end
      end
    end
  end
end
