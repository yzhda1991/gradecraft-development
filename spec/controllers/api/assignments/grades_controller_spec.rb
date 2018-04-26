describe API::Assignments::GradesController do
  let(:course) { build :course }
  let(:assignment) { create :assignment, course: course }

  before(:each) { login_user user }

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

    describe "#release" do
      let!(:grades) { create_list :grade, 2, assignment: assignment }
      let(:grade_updater_job) { instance_double "GradeUpdaterJob", enqueue: true }

      before(:each) { allow(GradeUpdaterJob).to receive(:new).and_return grade_updater_job }

      context "when grade ids are provided" do
        it "releases only the grades that are specified" do
          expect(grade_updater_job).to receive(:enqueue).once

          put :release, params: { assignment_id: assignment.id, grade_ids: grades.first.id }, format: :json

          expect(grades.first.reload).to have_attributes instructor_modified: true,
            student_visible: true, complete: true
        end
      end

      context "when grade ids are not provided" do
        it "releases all grades for the assignment" do
          expect(grade_updater_job).to receive(:enqueue).twice

          put :release, params: { assignment_id: assignment.id }, format: :json

          expect(grades.each(&:reload)).to all have_attributes instructor_modified: true,
            student_visible: true, complete: true
        end
      end
    end
  end

  context "as a student" do
    let(:user) { build_stubbed :user, courses: [course], role: :student }

    describe "protected routes" do
      it "redirect with a status 302" do
        [
          -> { get :show, params: { assignment_id: assignment.id }, format: :json },
          -> { put :release, params: { assignment_id: assignment.id }, format: :json }
        ].each do |protected_route|
          expect(protected_route.call).to have_http_status :redirect
        end
      end
    end
  end
end
