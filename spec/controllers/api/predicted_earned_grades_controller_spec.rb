require "spec_helper"
include SessionHelper

describe API::PredictedEarnedGradesController do
  let(:course) { create :course}
  let(:student)  { create(:course_membership, :student, course: course).user }
  let(:assignment) { create(:assignment) }
  let(:params) {{ assignment_id: assignment.id, predicted_points: (assignment.full_points * 0.75).to_i }}


  context "as student" do
    before do
      login_user(student)
      allow(controller).to receive(:current_course).and_return(course)
    end

    describe "POST create" do

      it "creates a new predicted earned grade" do
        expect{ post :create, params: { predicted_earned_grade: params }, format: :json }.to change(PredictedEarnedGrade, :count).by(1)
      end

      it "updates the predicted points for assignment and current user" do
        post :create, params: { predicted_earned_grade: params }, format: :json
        expect(PredictedEarnedGrade.where(student: student, assignment: assignment).first.predicted_points).to eq(params[:predicted_points])
        expect(response.status).to eq(201)
      end

      it "renders a 400 if a prediction exists for assignment and student" do
        predicted_earned_grade = create(:predicted_earned_grade, assignment: assignment, student: student)
        post :create, params: { predicted_earned_grade: params }, format: :json
        expect(response.status).to eq(400)
      end
    end

    describe "PUT update" do
      it "updates the predicted points for a grade" do
        predicted_earned_grade = create(:predicted_earned_grade, assignment: assignment, student: student)
        predicted_points = (assignment.full_points * 0.75).to_i
        put :update, params: { id: predicted_earned_grade.id, predicted_earned_grade: params }, format: :json
        expect(PredictedEarnedGrade.where(student: student, assignment: assignment).first.predicted_points).to eq(predicted_points)
        expect(response.status).to eq(200)
      end

      it "renders a 404 if prediction not found" do
        put :update, params: { id: 0, predicted_earned_grade: params }, format: :json
        expect(response.status).to eq(404)
      end
    end
  end
end
