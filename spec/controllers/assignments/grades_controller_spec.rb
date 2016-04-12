require "rails_spec_helper"

describe Assignments::GradesController do
  before(:all) do
    @course = create(:course_accepting_groups)
    @assignment = create(:assignment, course: @course)
    @student = create(:user)
    @student.courses << @course
    @grade = create :grade, student: @student, assignment: @assignment,
      course: @course
  end
  after(:each) { @grade.delete }

  context "as professor" do
    before(:all) do
      @professor = create(:user)
      CourseMembership.create user: @professor, course: @course, role: "professor"
    end

    before (:each) { login_user(@professor) }

    describe "GET mass_edit" do
      it "assigns params" do
        get :mass_edit, assignment_id: @assignment.id
        expect(assigns(:title)).to eq("Quick Grade #{@assignment.name}")
        expect(assigns(:assignment)).to eq(@assignment)
        expect(assigns(:assignment_type)).to eq(@assignment.assignment_type)
        expect(assigns(:assignment_score_levels)).to eq(@assignment.assignment_score_levels)
        expect(assigns(:grades)).to eq([@grade])
        expect(assigns(:students)).to eq([@student])
        expect(response).to render_template(:mass_edit)
      end

      it "creates missing grades and orders grades by student name" do
        student_2 = create(:user, last_name: "zzimmer", first_name: "aaron")
        student_3 = create(:user, last_name: "zzimmer", first_name: "zoron")
        [student_2,student_3].each {|s| s.courses << @course }
        expect{ get :mass_edit, assignment_id: @assignment.id }.to \
          change{Grade.count}.by(2)
        expect(assigns(:grades)[1].student).to eq(student_2)
        expect(assigns(:grades)[2].student).to eq(student_3)
      end

      context "with teams" do
        it "assigns params" do
          team = create(:team, course: @course)
          team.students << @student
          get :mass_edit, assignment_id: @assignment.id, team_id: team.id
          expect(assigns(:students)).to eq([@student])
          expect(assigns(:team)).to eq(team)
        end
      end
    end
  end

  context "as student" do
    before do
      login_user(@student)
      allow(controller).to receive(:current_student).and_return(@student)
    end

    it "redirects back to the root" do
      expect(get :mass_edit, { assignment_id: @assignment.id  }).to \
        redirect_to(:root)
    end
  end
end
