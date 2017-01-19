require "rails_spec_helper"
include SessionHelper

describe API::ChallengesController  do
  let(:course) { create :course, add_team_score_to_student: true }
  let(:student)  { create(:course_membership, :student, course: course).user }
  let(:professor) { create(:course_membership, :professor, course: course).user }
  let!(:challenge) { create(:challenge, course: course) }

  context "as professor" do
    before do
      login_user(professor)
      allow(controller).to receive(:current_course).and_return(course)
      allow(controller).to receive(:current_user).and_return(professor)
    end

    describe "GET index" do
      it "assigns challenges, no grade or student" do
        get :index, format: :json
        expect(assigns(:challenges).first.id).to eq(challenge.id)
        expect(assigns :student).to be_nil
        expect(assigns :predicted_earned_challenges).to be_nil
        expect(assigns :grades).to be_nil
        expect(response).to render_template(:index)
      end
    end
  end

  context "as student" do
    let!(:predicted_earned_challenge) { create :predicted_earned_challenge, student: student, challenge: challenge }
    let(:team) { create :team, course: course }
    let!(:grade) { create :challenge_grade, team: team, challenge: challenge }

    before do
      team.students << student
      login_user(student)
      allow(controller).to receive(:current_course).and_return(course)
      allow(controller).to receive(:current_user).and_return(student)
    end

    describe "GET index" do
      it "assigns the challenges with predictions and grades and a call to update" do
        get :index, format: :json
        expect(assigns(:challenges).first.id).to eq(challenge.id)
        expect(assigns :student).to eq(student)
        expect(assigns :predicted_earned_challenges).to eq([predicted_earned_challenge])
        expect(assigns :grades).to eq([grade])
        expect(assigns(:allow_updates)).to be_truthy
        expect(response).to render_template(:index)
      end
    end
  end

  context "as faculty previewing as student" do
    before do
      login_as_impersonating_agent(professor, student)
      allow(controller).to receive(:current_course).and_return(course)
      allow(controller).to receive(:current_user).and_return(student)
    end

    describe "GET index" do
      it "assigns false for updating predictions" do
        get :index, format: :json
        expect(assigns(:allow_updates)).to be_falsey
      end
    end
  end
end
