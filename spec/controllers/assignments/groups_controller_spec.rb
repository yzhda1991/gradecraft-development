require "rails_spec_helper"

describe Assignments::GroupsController do
  before(:all) do
    @course = create(:course_accepting_groups)
    @assignment = create(:assignment, course: @course)
    @student = create(:user)
    @student.courses << @course
  end
  before(:each) do
    @grade = create :grade, student: @student, assignment: @assignment,
      course: @course
  end
  after(:each) { @grade.delete }

  context "as a professor" do
    before(:all) do
      @professor = create(:user)
      CourseMembership.create user: @professor, course: @course, role: "professor"
    end
    before (:each) { login_user(@professor) }

    describe "GET grade" do
      it "assigns params" do
        group = create(:group)
        @assignment.groups << group
        group.students << @student
        get :grade, { assignment_id: @assignment.id, id: group.id }
        expect(assigns(:title)).to \
          eq("Grading #{group.name}'s #{@assignment.name}")
        expect(assigns(:assignment)).to eq(@assignment)
        expect(assigns(:assignment_score_levels)).to \
          eq(@assignment.assignment_score_levels)
        expect(assigns(:group)).to eq(group)
        expect(response).to render_template(:grade)
      end
    end
  end

  context "as student" do
    before do
      login_user(@student)
      allow(controller).to receive(:current_student).and_return(@student)
    end

    describe "GET grade" do
      it "redirects back to the root" do
        group = create(:group)
        @assignment.groups << group
        group.students << @student
        expect(get :grade, { assignment_id: @assignment.id, id: group.id }).to \
          redirect_to(:root)
      end
    end
  end
end
