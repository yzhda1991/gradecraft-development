describe API::Courses::StudentsController do
  let!(:course) { build(:course)}
  let(:student) { build :user, courses: [course], role: :student }

  context "as a professor" do
    let(:professor) { build :user, courses: [course], role: :professor }

    before(:each) do
      login_user professor
      allow(controller).to receive(:current_course).and_return course
    end

    describe "GET index" do
      let!(:earned_badge) { create :earned_badge, course: course, student: student }

      it "assigns earned badges for students in the course" do
        get :index, params: { course_id: course.id }, format: :json
        expect(assigns(:earned_badges)).to eq [earned_badge]
      end

      it "assigns students in the course" do
        get :index, params: { course_id: course.id }, format: :json
        expect(assigns(:students)).to eq [student]
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
