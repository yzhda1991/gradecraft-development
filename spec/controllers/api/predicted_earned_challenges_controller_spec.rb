require "rails_spec_helper"
include SessionHelper

describe API::PredictedEarnedChallengesController do
  let(:course) { create :course}
  let(:student)  { create(:course_membership, :student, course: course).user }
  let(:team) { create :team }
  let(:challenge) { create(:challenge) }
  let(:params) {{ challenge_id: challenge.id, predicted_points: (challenge.full_points * 0.75).to_i }}

  context "as student" do
    before do
      team.students << student
      login_user(student)
      allow(controller).to receive(:current_course).and_return(course)
      allow(course).to receive(:add_team_score_to_student).and_return(true)
      allow(student).to receive(:team_for_course).and_return(team)
    end

    describe "POST create" do

      it "creates a new predicted earned challenge" do
        expect{ post :create, params: { predicted_earned_challenge: params }, format: :json }.to change(PredictedEarnedChallenge, :count).by(1)
      end

      it "updates the predicted points for challenge and current user" do
        post :create, params: { predicted_earned_challenge: params }, format: :json
        expect(PredictedEarnedChallenge.where(student: student, challenge: challenge).first.predicted_points).to eq(params[:predicted_points])
        expect(response.status).to eq(201)
      end

      it "renders a 400 if a prediction exists for challenge and student" do
        predicted_earned_challenge = create(:predicted_earned_challenge, challenge: challenge, student: student)
        post :create, params: { predicted_earned_challenge: params }, format: :json
        expect(response.status).to eq(400)
      end
    end

    describe "PUT update" do
      it "updates the predicted points for a challenge" do
        predicted_earned_challenge = create(:predicted_earned_challenge, challenge: challenge, student: student)
        predicted_points = (challenge.full_points * 0.75).to_i
        put :update, params: { id: predicted_earned_challenge, predicted_earned_challenge: params }, format: :json
        expect(PredictedEarnedChallenge.where(student: student, challenge: challenge).first.predicted_points).to eq(predicted_points)
        expect(response.status).to eq(200)
      end

      it "renders a 404 if prediction not found" do
        put :update, params: { id: 0, predicted_earned_challenge: params }, format: :json
        expect(response.status).to eq(404)
      end
    end
  end
end
