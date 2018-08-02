describe API::GradingStatus::SubmissionsController do
  let(:course) { build :course }
  let(:student) { student_course_membership.user }
  let!(:student_course_membership) { create :course_membership, :student, course: course, active: true }

  before(:each) { allow(controller).to receive(:current_course).and_return course }

  context "as an instructor" do
    let(:professor) { create :user, courses: [course], role: :professor }

    before(:each) { login_user professor }

    describe "GET ungraded" do
      let(:assignment) { build :assignment, course: course }
      let!(:graded_submission) { create :graded_submission, course: course, assignment: assignment, student: student }
      let!(:ungraded_submission) { create :submission, course: course, student: student }
      let!(:grade) do
        create :complete_grade, course: course, assignment: assignment,
          submission: graded_submission, student: student
      end

      it "assigns the ungraded submissions in the current course" do
        get :ungraded, format: :json
        expect(assigns(:submissions)).to eq [ungraded_submission]
      end
    end
  end

  context "as a student" do
    before(:each) { login_user student }

    describe "protected routes" do
      it "return a status 302" do
        [
          -> { get :ungraded, format: :json }
        ].each do |protected_route|
          expect(protected_route.call).to have_http_status :redirect
        end
      end
    end
  end
end
