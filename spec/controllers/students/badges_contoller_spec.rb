require "spec_helper"

describe Students::BadgesController do
  let(:course) { build(:course) }
  let(:student) { create(:course_membership, :student, course: course).user }
  let(:professor) { create(:course_membership, :professor, course: course).user }
  let(:badge) { create(:badge, course: course) }

  context "as professor" do

    before(:each) do
      login_user(professor)
      allow(controller).to receive(:current_student).and_return(student)
    end

    describe "GET index" do
      it "returns badges for the current course" do
        get :index, params: { student_id: student.id }
        expect(response).to render_template("badges/index")
      end
    end

    describe "GET show" do
      it "displays the badge page" do
        get :show, params: { student_id: student.id, id: badge.id }
        expect(response).to render_template("badges/show")
      end
    end
  end
end
