describe API::Assignments::GradesController do
  let(:course) { build :course }
  let(:assignment) { create :assignment }

  before(:each) do
    login_user user
  end

  context "as a professor" do
    let(:user) { build_stubbed :user, courses: [course], role: :professor }

    describe "#show" do
      let(:students) { build_list :user, 3, courses: [course], role: :student }
      let!(:grade) { create :grade, student: students.first, assignment: assignment, course: course }

      context "when the team id is provided" do
        let(:team) { build :team, course: course }

        before(:each) do
          [students.first, students.second].each do |student|
            create :team_membership, student: student, team: team
          end
        end

        it "returns grades for each student in the team" do
          get :show, params: { assignment_id: assignment.id, team_id: team.id },
            format: :json

          expect(assigns(:assignment)).to eq assignment
          expect(assigns(:grades).length).to eq 2
          expect(assigns(:grades)).to include grade
          expect(response).to render_template :show
        end
      end

      context "when the team id is not provided" do
        it "returns a grade for each student in the course" do
          get :show, params: { assignment_id: assignment.id }, format: :json

          expect(assigns(:assignment)).to eq assignment
          expect(assigns(:grades).length).to eq 3
          expect(assigns(:grades)).to include grade
          expect(response).to render_template :show
        end
      end
    end
  end

  context "as a student" do
    let(:user) { build_stubbed :user, courses: [course], role: :student }

    describe "#show" do
      it "is a protected route" do
        get :show, params: { assignment_id: assignment.id }, format: :json

        expect(response).to have_http_status 302
      end
    end
  end
end
