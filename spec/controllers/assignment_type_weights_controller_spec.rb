require "spec_helper"

describe AssignmentTypeWeightsController do
  let(:course) { build(:course) }
  let(:student) { create(:course_membership, course: course, role: :student).user}
  let(:professor) { create(:course_membership, :professor, course: course).user }

  context "as student" do

    before(:each) do
      login_user(student)
    end

    describe "GET index" do
      it "returns index page for weights" do
        get :index
        expect(response).to render_template("index")
      end
    end
  end
end
