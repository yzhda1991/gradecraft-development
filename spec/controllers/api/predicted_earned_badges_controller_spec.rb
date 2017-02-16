require "spec_helper"
include SessionHelper

describe API::PredictedEarnedBadgesController do
  let(:course) { create :course}
  let(:student)  { create(:course_membership, :student, course: course).user }
  let(:badge) { create :badge }
  let(:params) {{ badge_id: badge.id, predicted_times_earned: 2 }}

  context "as student" do
    before(:each) { login_user(student) }

    describe "POST create" do

      it "creates a new predicted earned badge" do
        expect{ post :create, params: { predicted_earned_badge: params }, format: :json }.to \
          change(PredictedEarnedBadge, :count).by(1)
      end

      it "updates the predicted points for badge and current user" do
        post :create, params: { predicted_earned_badge: params }, format: :json
        expect(PredictedEarnedBadge.where(student: student, badge: badge).first.predicted_times_earned).to eq(2)
        expect(response.status).to eq(201)
      end

      it "renders a 400 if a prediction exists for badge and student" do
        predicted_earned_badge = create(:predicted_earned_badge, badge: badge, student: student)
        post :create, params: { predicted_earned_badge: params }, format: :json
        expect(response.status).to eq(400)
      end
    end


    describe "PUT update" do
      it "updates the predicted times earned for a badge" do
        peb = create(:predicted_earned_badge, badge: badge, student: student)
        put :update, params: { id: peb.id, predicted_earned_badge: params }, format: :json
        expect(PredictedEarnedBadge.where(student: student, badge: badge).first.predicted_times_earned).to eq(2)
        expect(response.status).to eq(200)
      end
    end
  end
end
