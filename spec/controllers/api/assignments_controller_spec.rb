require "rails_spec_helper"
include SessionHelper

describe API::AssignmentsController , focus: true do
  let(:course) { create :course}
  let(:student)  { create(:student_course_membership, course: course).user }
  let(:professor) { create(:professor_course_membership, course: course).user }
  let!(:assignment) { create(:assignment, course: course) }

  context "as professor" do
    before do
      login_user(professor)
      allow(controller).to receive(:current_course).and_return(course)
      allow(controller).to receive(:current_user).and_return(professor)
    end

    describe "GET index" do
      it "assigns assignments, no grade or student" do
        get :index, format: :json
        expect(assigns(:assignments).first.id).to eq(assignment.id)
        expect(assigns :student).to be_nil
        expect(assigns :predicted_earned_grades).to be_nil
        expect(assigns :grades).to be_nil
        expect(response).to render_template(:index)
      end
    end
  end

  context "as student" do
    let!(:predicted_earned_grade) { create :predicted_earned_grade, student: student, assignment: assignment }
    let!(:grade) { create :grade, student: student, assignment: assignment }

    before do
      login_user(student)
      allow(controller).to receive(:current_course).and_return(course)
      allow(controller).to receive(:current_user).and_return(student)
    end

    describe "GET index" do
      it "assigns the attributes with call to update" do
        get :index, format: :json
        expect(assigns(:assignments).first.id).to eq(assignment.id)
        expect(assigns :student).to eq(student)
        expect(assigns :predicted_earned_grades).to eq([predicted_earned_grade])
        expect(assigns :grades).to eq([grade])
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
        expect(assigns(:update_predictions)).to be_falsy
      end
    end
  end
end
