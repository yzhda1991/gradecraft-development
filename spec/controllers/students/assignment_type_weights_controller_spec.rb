require "spec_helper"

describe Students::AssignmentTypeWeightsController do
  let(:world) { World.create.with(:course, :student) }
  let(:professor) { create(:course_membership, :professor, course: world.course).user }

  context "as professor" do

    before(:each) do
      login_user(professor)
      allow(controller).to receive(:current_student).and_return(world.student)
    end

    describe "GET index" do
      it "returns badges for the current course" do
        get :index, params: { student_id: world.student.id }
        expect(response).to render_template("assignment_type_weights/index")
      end
    end
  end
end
