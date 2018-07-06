describe Assignments::Groups::GradesController do
  let(:course) { create(:course) }
  let(:assignment_with_groups) { create(:group_assignment, course: course) }

  context "as a professor" do
    let(:professor) { create(:user) }
    let!(:professor_membership) { create(:course_membership, :professor, user: professor, course: course) }

    before(:each) do
      login_user(professor)
      allow(controller).to receive(:current_course).and_return(course)
    end

    describe "GET mass_edit" do
      before(:each) do
        allow(controller).to receive(:current_course).and_return(course)
      end

      it "renders the mass_edit template" do
        get :mass_edit, params: { assignment_id: assignment_with_groups }
        expect(response).to render_template(:mass_edit)
      end
    end

    describe "PUT mass_update" do
      let(:group) { create(:group, course: course) }
      let(:group_2) { create(:group, course: course) }
      let!(:assignment_group) { create(:assignment_group, group: group, assignment: assignment_with_groups) }
      let!(:assignment_group_2) { create(:assignment_group, group: group_2, assignment: assignment_with_groups) }

      context "with raw points being blank" do
        let(:params) do
          {
            "0" => { graded_by_id: professor.id,
              "group_id" => group_2.id, raw_points: "",
              assignment: assignment_with_groups.id
            }
          }
        end

        it "should not create grades for the students" do
          put :mass_update, params: { assignment_id: assignment_with_groups.id,
            assignment: { grades_by_group: params }}
          expect(assignment_with_groups.reload.grades.count).to be_zero
        end
      end

      context "with raw points not being blank" do
        let(:params) do
          {
            "0" => { graded_by_id: professor.id,
              "group_id" => group.id, raw_points: 1000,
              assignment: assignment_with_groups.id
            }
          }
        end

        it "should create grades for the students" do
          put :mass_update, params: { assignment_id: assignment_with_groups.id,
            assignment: { grades_by_group: params }}
          expect(assignment_with_groups.reload.grades.count).to eq(group.students.count)
        end

        it "updates the grade attributes" do
          put :mass_update, params: { assignment_id: assignment_with_groups.id,
            assignment: { grades_by_group: params }}
          grade = Grade.unscoped.last
          expect(grade.graded_by_id).to eq(professor.id)
          expect(grade.instructor_modified).to be true
          expect(grade.raw_points).to eq(1000)
          expect(grade.complete).to be true
          expect(grade.student_visible).to be true
        end

        it "redirects on failure" do
          allow(Services::CreatesManyGroupGrades).to \
            receive(:call).and_return double(:result, success?: false, message: "")
          put :mass_update, params: { assignment_id: assignment_with_groups.id,
            assignment: { grades_by_group: params }}
          expect(response).to \
            redirect_to(mass_edit_assignment_groups_grades_path(assignment_with_groups))
        end
      end
    end
  end

  context "as a student" do
    let(:student) { create(:course_membership, :student, course: course).user }

    before(:each) do
      login_user(student)
    end

    describe "GET mass_edit" do
      it "redirects back to the root" do
        expect(get :mass_edit, params: { assignment_id: assignment_with_groups.id }).to \
          redirect_to(:root)
      end
    end

    describe "PUT mass_update" do
      it "redirects back to the root" do
        expect(get :mass_update, params: { assignment_id: assignment_with_groups.id }).to \
          redirect_to(:root)
      end
    end
  end
end
