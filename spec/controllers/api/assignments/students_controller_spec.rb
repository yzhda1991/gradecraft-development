describe API::Assignments::StudentsController do
  let(:course) { build :course }
  let(:assignment) { create :assignment, course: course }

  before(:each) do
    login_user user
    allow(controller).to receive(:current_course).and_return course
  end

  context "as an instructor" do
    let(:user) { build_stubbed :user, courses: [course], role: :professor }
    let!(:students) { create_list :user, 3, courses: [course], role: :student }

    describe "#index" do
      it "returns only the student ids for the assignment if requested" do
        get :index, params: { assignment_id: assignment.id, fetch_ids: 1 }, format: :json

        body = JSON.parse(response.body)
        expect(body).to include "student_ids"
        expect(body["student_ids"]).to match_array students.pluck(:id)
      end

      it "returns only a subset of the students if provided" do
        get :index, params: { assignment_id: assignment.id, student_ids: students.first.id }, format: :json

        expect(assigns(:students)).to eq [students.first]
        expect(response).to render_template :index
      end

      it "returns all students for the course if none are specified" do
        get :index, params: { assignment_id: assignment.id }, format: :json

        expect(assigns(:students)).to match_array students
      end

      it "assigns the assignment" do
        get :index, params: { assignment_id: assignment.id }, format: :json
        expect(assigns(:assignment)).to eq assignment
      end
    end
  end

  context "as a student" do
    let(:user) { build_stubbed :user, courses: [course], role: :student }

    describe "protected routes" do
      it "redirect with a status 302" do
        [
          -> { get :index, params: { assignment_id: assignment.id }, format: :json }
        ].each do |protected_route|
          expect(protected_route.call).to have_http_status :redirect
        end
      end
    end
  end
end
