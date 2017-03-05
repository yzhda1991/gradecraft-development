require "spec_helper"

describe Students::AssignmentTypeWeightsController do
  let(:course) { create :course }
  let(:professor) { create(:course_membership, :professor, course: course).user }
  let(:student) { create(:course_membership, :student, course: course).user }

  context "as professor" do

    before(:each) do
      login_user(professor)
      allow(controller).to receive(:current_student).and_return(student)
    end

    describe "GET index" do
      it "returns badges for the current course" do
        get :index, params: { student_id: student.id }
        expect(response).to render_template("assignment_type_weights/index")
      end
    end
  end
end
