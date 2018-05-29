describe API::Courses::StudentsController do
  let!(:course) { build :course }
  let(:student) { students.first }
  let(:students) { build_list :user, 2, courses: [course], role: :student }

  context "as a professor" do
    let(:professor) { build :user, courses: [course], role: :professor }

    before(:each) do
      login_user professor
      allow(controller).to receive(:current_course).and_return course
    end

    describe "GET index" do
      let!(:earned_badge) { create :earned_badge, course: course, student: student }

      context "when student ids are requested" do
        it "returns only ids" do
          get :index, params: { course_id: course.id, fetch_ids: "1" }, format: :json
          body = JSON.parse(response.body)
          expect(body).to include "student_ids"
          expect(body["student_ids"]).to match_array students.pluck(:id)
        end
      end

      context "when students ids are not requested" do
        context "with a provided subset of student ids" do
          let(:student_ids) { [student.id] }

          it "assigns only a subset of students in the course" do
            get :index, params: { course_id: course.id, student_ids: student_ids }, format: :json
            expect(assigns(:students)).to eq [student]
          end
        end

        context "without a provided subset of student ids" do
          it "assigns earned badges for students in the course" do
            get :index, params: { course_id: course.id }, format: :json
            expect(assigns(:earned_badges)).to eq [earned_badge]
          end

          it "assigns all students in the course" do
            get :index, params: { course_id: course.id }, format: :json
            expect(assigns(:students)).to match_array students
          end
        end
      end
    end
  end

  context "as a student" do
    before(:each) { login_user student }

    describe "protected routes" do
      it "redirects with a status 302" do
        [
          -> { get :index, params: { course_id: course.id }, format: :json }
        ].each do |protected_route|
          expect(protected_route.call).to have_http_status :redirect
        end
      end
    end
  end
end
