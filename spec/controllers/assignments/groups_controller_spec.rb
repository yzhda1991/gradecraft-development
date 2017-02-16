require "spec_helper"

describe Assignments::GroupsController do
  before(:all) do
    @course = create(:course)
    @assignment = create(:assignment, course: @course)
    @student = create(:user, courses: [@course], role: :student)
  end
  before(:each) do
    @grade = create :grade, student: @student, assignment: @assignment,
      course: @course
  end
  after(:each) { @grade.delete }

  context "as a professor" do
    before(:all) do
      @professor = create(:user, courses: [@course], role: :professor)
    end
    before(:each) { login_user(@professor) }

    describe "GET grade" do
      it "assigns params" do
        group = create(:group)
        submission = create(:group_submission, assignment: @assignment, group: group)
        @assignment.groups << group
        group.students << @student
        get :grade, params: { assignment_id: @assignment.id, id: group.id }
        expect(assigns(:assignment)).to eq(@assignment)
        expect(assigns(:assignment_score_levels)).to \
          eq(@assignment.assignment_score_levels)
        expect(assigns(:group)).to eq(group)
        expect(assigns(:submission)).to eq(submission)
        expect(response).to render_template(:grade)
      end
    end
  end

  context "as student" do
    let(:group) { create :group }

    before do
      @assignment.groups << group
      group.students << @student
      login_user(@student)
      allow(controller).to receive(:current_student).and_return(@student)
    end

    describe "GET grade" do
      it "redirects back to the root" do
        expect(get :grade, params: { assignment_id: @assignment.id, id: group.id }).to \
          redirect_to(:root)
      end
    end
  end
end
