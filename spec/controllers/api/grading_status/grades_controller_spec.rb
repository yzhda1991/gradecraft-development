describe API::GradingStatus::GradesController do
  let(:course) { build :course }
  let(:student) { build :user, courses: [course], role: :student }

  before(:each) { allow(controller).to receive(:current_course).and_return course }

  context "as an instructor" do
    let(:professor) { build_stubbed :user, courses: [course], role: :professor }

    before(:each) { login_user professor }

    describe "GET ungraded" do
      let!(:complete_grade) { create :complete_grade, course: course, student: student }
      let!(:in_progress_grade) { create :in_progress_grade, course: course, student: student }

      it "assigns the in progress grades for the current course" do
        get :in_progress, format: :json
        expect(assigns(:grades)).to eq [in_progress_grade]
      end
    end
  end

  context "as a student" do
    before(:each) { login_user student }

    describe "protected routes" do
      it "return a status 302" do
        [
          -> { get :in_progress, format: :json }
        ].each do |protected_route|
          expect(protected_route.call).to have_http_status :redirect
        end
      end
    end
  end
end
