describe Assignments::GroupsController do
  let(:course) { build(:course)}
  let!(:student)  { create(:course_membership, :student, course: course).user }
  let(:professor) { create(:course_membership, :professor, course: course).user }
  let(:assignment) { create(:assignment, course: course) }
  let(:grade) { create(:grade, student: student, assignment: assignment) }

  context "as a professor" do
    before(:each) { login_user(professor) }

    describe "GET grade" do

      let(:group) { create :group }
      let!(:submission) { create(:group_submission, assignment: assignment, group: group) }

      before do
        assignment.groups << group
        group.students << student
      end

      it "assigns params" do
        get :grade, params: { assignment_id: assignment.id, id: group.id }
        expect(assigns(:assignment)).to eq(assignment)
        expect(assigns(:assignment_score_levels)).to \
          eq(assignment.assignment_score_levels)
        expect(assigns(:group)).to eq(group)
        expect(assigns(:submission)).to eq(submission)
        expect(response).to render_template(:grade)
      end

      it "sets the grade to incomplete and not student visible before load" do
        grade.update(complete: true, student_visible: true)
        get :grade, params: { assignment_id: assignment.id, id: group.id }
        expect(grade.reload.complete).to be_falsey
        expect(grade.reload.student_visible).to be_falsey
      end
    end
  end

  context "as student" do
    let(:group) { create :group }

    before do
      assignment.groups << group
      group.students << student
      login_user(student)
      allow(controller).to receive(:current_student).and_return(student)
    end

    describe "GET grade" do
      it "redirects back to the root" do
        expect(get :grade, params: { assignment_id: assignment.id, id: group.id }).to \
          redirect_to(:root)
      end
    end
  end
end
