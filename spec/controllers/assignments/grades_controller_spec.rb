describe Assignments::GradesController do
  let(:course) { build(:course) }
  let(:professor) { create(:course_membership, :professor, course: course).user }
  let!(:student) { create(:course_membership, :student, course: course).user }
  let(:assignment) { create(:assignment, course: course) }
  let(:assignment_with_groups) { create(:group_assignment, course: course) }
  let!(:grade) { create(:grade, student: student, assignment: assignment, course: course) }

  context "as professor" do
    before(:each) { login_user(professor) }

    describe "GET export" do
      it "returns sample csv data" do
        submission = create(:submission, grade: grade, student: student,
                            assignment: assignment)
        get :export, params: { assignment_id: assignment }, format: :csv

        expect(response.body).to \
          include("First Name,Last Name,Email,Score,Feedback,Raw Score,Statement")
      end
    end

    describe "GET export_earned_levels" do
      it "returns example earned levels data" do
        rubric = create(:rubric_with_criteria, assignment: assignment)
        rubric.criteria.each do |criterion|
          level = Level.create(criterion_id: criterion.id, name: "Sushi Success", points: 2000)
          CriterionGrade.create(criterion: criterion, level_id: level.id, student: student, points: 2000, assignment: assignment)
        end
        get :export_earned_levels, params: { assignment_id: assignment }, format: :csv

        expect(response.body).to \
          include("First Name,Last Name,Email,Username,Team")
      end
    end

    describe "GET index" do
      it "redirects to the assignments show view if the assignment is not a rubric" do
        allow(assignment).to receive(:grade_with_rubric?).and_return false
        get :index, params: { assignment_id: assignment.id }
        expect(response).to redirect_to assignment_path(assignment)
      end
    end

    describe "GET mass_edit" do
      it "assigns the assignment" do
        get :mass_edit, params: { assignment_id: assignment.id }

        expect(assigns(:assignment)).to eq(assignment)
        expect(response).to render_template :mass_edit
      end
    end

    describe "PUT mass_update" do
      context "when the assignment is not pass fail type" do
        context "with raw points not being blank" do
          let(:grades_attributes) do
            { "#{assignment.reload.grades.to_a.index(grade)}" =>
              { graded_by_id: professor.id, id: grade.id,
                student_id: grade.student_id, raw_points: 1000,
                student_visible: true, complete: true
              }
            }
          end

          it "updates the grade for the specific assignment" do
            put :mass_update, params: { assignment_id: assignment.id,
              assignment: { grades_attributes: grades_attributes }}
            expect(grade.reload.raw_points).to eq 1000
            expect(grade.reload.instructor_modified).to be_truthy
            expect(grade.reload.complete).to be_truthy
            expect(grade.reload.student_visible).to be_truthy
          end

          it "timestamps the grades" do
            current_time = DateTime.now
            put :mass_update, params: { assignment_id: assignment.id,
              assignment: { grades_attributes: grades_attributes }}
            expect(grade.reload.graded_at).to_not be_nil
            expect(grade.reload.graded_at).to be > current_time
          end

          it "redirects to assignment path with a team" do
            team = create(:team, course: course)
            put :mass_update, params: { assignment_id: assignment.id, team_id: team.id,
              assignment: { grades_attributes: grades_attributes }}
            expect(response).to \
              redirect_to(assignment_path(assignment, team_id: team.id))
          end

          it "redirects on failure" do
            allow(Services::CreatesManyGrades).to \
              receive(:call).and_return double(:result, success?: false, message: "")
            put :mass_update, params: { assignment_id: assignment.id,
              assignment: { grades_attributes: grades_attributes }}
            expect(response).to \
              redirect_to(mass_edit_assignment_grades_path(assignment))
          end
        end

        context "with raw points being blank" do
          let(:grades_attributes) do
            { "#{assignment.reload.grades.to_a.index(grade)}" =>
              { graded_by_id: professor.id, id: grade.id,
                student_id: grade.student_id, raw_points: ""
              }
            }
          end

          it "does not update the grade for the specific assignment" do
            raw_points_prior = grade.raw_points
            put :mass_update, params: { assignment_id: assignment.id,
              assignment: { grades_attributes: grades_attributes }}
            expect(grade.reload.raw_points).to eq raw_points_prior
          end
        end
      end

      context "when the assignment is of pass/fail type" do
        context "with pass fail status being blank" do
          let(:grades_attributes) do
            { "#{assignment.reload.grades.to_a.index(grade)}" =>
              { graded_by_id: professor.id, id: grade.id,
                student_id: grade.student_id, pass_fail_status: ""
              }
            }
          end

          it "does not update the grade for the specific assignment" do
            raw_points_prior = grade.raw_points
            put :mass_update, params: { assignment_id: assignment.id,
              assignment: { grades_attributes: grades_attributes }}
            expect(grade.reload.raw_points).to eq raw_points_prior
          end
        end

        context "with pass fail status set to pass" do
          let(:grades_attributes) do
            { "#{assignment.reload.grades.to_a.index(grade)}" =>
              { graded_by_id: professor.id, id: grade.id,
                student_id: grade.student_id, pass_fail_status: "Pass"
              }
            }
          end

          it "updates the grade for the specific assignment" do
            put :mass_update, params: { assignment_id: assignment.id,
              assignment: { grades_attributes: grades_attributes }}
            expect(grade.reload.instructor_modified).to be true
            expect(grade.reload.student_visible).to be_truthy
            expect(grade.reload.pass_fail_status).to eq "Pass"
          end
        end
      end
    end

    describe "POST self_log" do
      it "redirects back to the root" do
        expect(post :self_log, params: { assignment_id: assignment.id }).to \
          redirect_to(:root)
      end
    end

    describe "DELETE delete_all" do
      context "when there is no team id" do
        it "deletes all the grades for the assignment" do
          delete :delete_all, params: { assignment_id: assignment.id }
          expect(assignment.reload.grades).to be_empty
        end
      end

      context "when there is a team id" do
        let!(:other_student) { create(:course_membership, :student, course: course).user }
        let!(:other_grade) { create(:grade, assignment: assignment, course: course, student: other_student) }
        let(:team) { create(:team, course: course) }
        let!(:team_membership) { create(:team_membership, team: team, student: student) }

        it "deletes only the grades for the team on the assignment" do
          expect { delete :delete_all, params: { assignment_id: assignment.id, team_id: team.id }}.to \
            change { assignment.reload.grades.count }.by(-1)
        end
      end

      it "redirects to assignments page on success" do
        delete :delete_all, params: { assignment_id: assignment.id }
        expect(response).to redirect_to(assignment_path(assignment))
      end
    end
  end

  context "as student" do
    before do
      login_user(student)
      allow(controller).to receive(:current_student).and_return(student)
    end

    describe "POST self_log" do
      context "with a student loggable grade" do
        before(:each) { assignment.update(student_logged: true) }

        it "creates a maximum score by the student if present" do
          post :self_log, params: { assignment_id: assignment.id }
          grade = student.grade_for_assignment(assignment)
          expect(grade.raw_points).to eq assignment.full_points
        end

        it "updates the attributes on the grade" do
          post :self_log, params: { assignment_id: assignment.id }
          grade = student.grade_for_assignment(assignment)
          grade.reload
          expect(grade.instructor_modified).to eq true
          expect(grade.student_visible).to eq true
          expect(grade.complete).to eq true
          expect(grade.graded_at).to be_within(1.second).of(DateTime.now)
        end

        it "reports errors on failure to save" do
          allow_any_instance_of(Grade).to receive(:save).and_return false
          post :self_log, params: { assignment_id: assignment.id }
          grade = student.grade_for_assignment(assignment)
          expect(flash[:notice]).to \
            eq("We're sorry, there was an error saving your grade.")
        end

        context "with assignment levels" do
          it "creates a score for the student at the specified level" do
            post :self_log, params: { assignment_id: assignment.id,
              grade: { raw_points: "10000" }}
            grade = student.grade_for_assignment(assignment)
            expect(grade.raw_points).to eq 10000
          end
        end
      end

      context "with an assignment not student loggable" do
        before(:each) { assignment.update(student_logged: false) }

        it "creates should not change the student score" do
          post :self_log, params: { assignment_id: assignment.id }
          grade = student.grade_for_assignment(assignment)
          expect(grade.raw_points).to eq nil
        end
      end
    end

    describe "GET export" do
      it "redirects back to the root" do
        expect(get :export, params: { assignment_id: assignment }, format: :csv).to \
          redirect_to(:root)
      end
    end

    describe "GET index" do
      it "redirects back to the root" do
        expect(get :index, params: { assignment_id: assignment }).to \
          redirect_to(:root)
      end
    end

    describe "GET mass_edit" do
      it "redirects back to the root" do
        expect(get :mass_edit, params: { assignment_id: assignment.id }).to \
          redirect_to(:root)
      end
    end

    describe "PUT mass_update" do
      it "redirects back to the root" do
        expect(get :mass_update, params: { assignment_id: assignment.id }).to \
          redirect_to(:root)
      end
    end
  end
end
