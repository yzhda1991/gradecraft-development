require "rails_spec_helper"

describe Assignments::GradesController do
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

    describe "PUT mass_update" do
      let(:grades_attributes) do
        { "#{@assignment.reload.grades.index(@grade)}" =>
          { graded_by_id: @professor.id, instructor_modified: true,
            student_id: @grade.student_id, raw_score: 1000, status: "Graded",
            id: @grade.id
          }
        }
      end

      it "updates the grades for the specific assignment" do
        put :mass_update, assignment_id: @assignment.id,
          assignment: { grades_attributes: grades_attributes }
        expect(@grade.reload.raw_score).to eq 1000
      end

      it "timestamps the grades" do
        current_time = DateTime.now
        put :mass_update, assignment_id: @assignment.id,
          assignment: { grades_attributes: grades_attributes }
        expect(@grade.reload.graded_at).to be > current_time
      end

      it "only sends notifications to the students if the grade changed" do
        @grade.update_attributes({ raw_score: 1000 })
        run_background_jobs_immediately do
          expect { put :mass_update, assignment_id: @assignment.id,
                   assignment: { grades_attributes: grades_attributes } }.to_not \
            change { ActionMailer::Base.deliveries.count }
        end
      end

      it "redirects to assignment path with a team" do
        team = create(:team, course: @course)
        put :mass_update, assignment_id: @assignment.id, team_id: team.id,
          assignment: { grades_attributes: grades_attributes }
        expect(response).to \
          redirect_to(assignment_path(@assignment, team_id: team.id))
      end

      it "redirects on failure" do
        allow_any_instance_of(Assignment).to \
          receive(:update_attributes).and_return false
        put :mass_update, assignment_id: @assignment.id,
          assignment: { grades_attributes: grades_attributes }
        expect(response).to \
          redirect_to(mass_edit_assignment_grades_path(@assignment))
      end
    end
  end

  context "as student" do
    before do
      login_user(@student)
      allow(controller).to receive(:current_student).and_return(@student)
    end

    describe "GET mass_edit" do
      it "redirects back to the root" do
        expect(get :mass_edit, { assignment_id: @assignment.id  }).to \
          redirect_to(:root)
      end
    end

    describe "PUT mass_update" do
      it "redirects back to the root" do
        expect(get :mass_update, { assignment_id: @assignment.id  }).to \
          redirect_to(:root)
      end
    end
  end
end
