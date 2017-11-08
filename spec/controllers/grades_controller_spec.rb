describe GradesController do
  let(:course) { build :course }
  let(:student) { create(:course_membership, :student, course: course).user }
  let(:assignment) { create :assignment, course: course }
  let(:grade) { create(:grade, student: student, assignment: assignment, course: course) }

  before do
    allow(Resque).to receive(:enqueue).and_return(true)
  end

  context "as professor" do
    let(:professor) { create(:course_membership, :professor, course: course).user }

    before do
      login_user(professor)
    end

    describe "GET show" do
      context "for a group grade" do
        let(:group) { create :group, course: course }
        let(:assignment) { create :group_assignment, course: course }
        let(:grade) { create :grade, group: group, assignment: assignment,
                        course: course, student_id: student.id }

        before do
          group.assignments << assignment
          group.students << student
        end

        it "renders the template" do
          get :show, params: { id: grade.id }
          expect(response).to render_template(:show)
        end
      end
    end

    describe "GET edit" do
      it "assigns grade parameters and renders edit" do
        get :edit, params: { id: grade.id }
        expect(assigns(:grade)).to eq(grade)
        expect(response).to render_template(:edit)
      end

      it "assigns existing submissions" do
        submission = create(:submission, student: student, assignment: assignment)
        get :edit, params: { id: grade.id }
        expect(assigns(:submission)).to eq(submission)
      end

      it "sets the grade to incomplete and not student visible before load" do
        grade.update(complete: true, student_visible: true)
        get :edit, params: { id: grade.id }
        expect(assigns(:grade).complete).to be_falsey
        expect(assigns(:grade).student_visible).to be_falsey
      end

      describe "on submit" do
        it "redirects to the assignment show page by default" do
          get :edit, params: { id: grade.id }
          expect(assigns(:submit_path)).to eq(assignment_path(grade.assignment))
        end

        describe "from the grading status page" do
          before do
            request.env["HTTP_REFERER"] = grading_status_path
          end

          it "redirects back to the grading status page" do
            get :edit, params: { id: grade.id }
            expect(assigns(:submit_path)).to eq(grading_status_path)
          end
        end

        it "includes the team filter if team is in the params" do
          team = create :team, course: course
          get :edit, params: { id: grade.id, team_id: team.id }
          expect(assigns(:submit_path)).to eq(assignment_path(grade.assignment) + "?team_id=#{team.id}")
        end
      end
    end

    describe "POST exclude" do
      before do
        allow_any_instance_of(ScoreRecalculatorJob).to \
          receive(:enqueue).and_return true
      end

      it "marks the Grade as excluded, but preserves the data" do
        grade.update(
          raw_points: 500,
          feedback: "should be nil",
          feedback_read: true,
          feedback_read_at: Time.now,
          feedback_reviewed: true,
          feedback_reviewed_at: Time.now,
          instructor_modified: true,
          graded_at: DateTime.now,
          student_visible: true
        )
        post :exclude, params: { id: grade }

        grade.reload
        expect(grade.excluded_from_course_score).to eq(true)
        expect(grade.raw_points).to eq(500)
        expect(grade.score).to eq(500)
      end

      it "adds exclusion metadata" do
        current_time = DateTime.now
        post :exclude, params: { id: grade }

        grade.reload
        expect(grade.excluded_at).to be > current_time
        expect(grade.excluded_by_id).to eq(professor.id)
      end

      it "returns an error message on failure" do
        allow_any_instance_of(Grade).to receive(:save).and_return false
        post :exclude, params: { id: grade }
        expect(flash[:alert]).to include("grade was not successfully excluded")
      end
    end

    describe "POST include" do
      before do
        allow_any_instance_of(ScoreRecalculatorJob).to \
          receive(:enqueue).and_return true
      end

      it "marks the Grade as included, and clears the excluded details" do
        grade.update(
          raw_points: 500,
          student_visible: true,
          excluded_from_course_score: true,
          excluded_by_id: 2,
          excluded_at: Time.now
        )
        post :include, params: { id: grade }

        grade.reload
        expect(grade.excluded_from_course_score).to eq(false)
        expect(grade.raw_points).to eq(500)
        expect(grade.score).to eq(500)
        expect(grade.excluded_by_id).to be nil
        expect(grade.excluded_at).to be nil
      end

      it "returns an error message on failure" do
        allow_any_instance_of(Grade).to receive(:save).and_return false
        post :include, params: { id: grade }
        expect(flash[:alert]).to include("grade was not successfully re-added")
      end
    end

    describe "PUT release" do
      it "updates the grade to student visible" do
        put :release, params: { grade_ids: [grade.id]}
        expect(grade.reload.student_visible).to be_truthy
      end
    end

    describe "DELETE destroy" do
      it "removes the grade entirely" do
        grade
        expect{ delete :destroy, params: { id: grade.id }}.to \
          change{Grade.count}.by(-1)
      end

      it "redirects to the assignments if the professor does not have access" do
        allow_any_instance_of(GradeProctor).to \
          receive(:destroyable?).and_return false
        expect(delete :destroy, params: { id: grade.id }).to \
          redirect_to(assignment_path(grade.assignment))
      end
    end

    describe "POST feedback_read" do
      it "should be protected and redirect to root" do
        expect(post :feedback_read, params: { id: grade.id }).to redirect_to(:root)
      end
    end
  end

  context "as student" do
    before do
      login_user(student)
      allow(controller).to receive(:current_student).and_return(student)
    end

    describe "GET show" do
      it "redirects to the assignment show page" do
        get :show, params: { id: grade.id }
        expect(response).to redirect_to(assignment_path(assignment))
      end
    end

    describe "POST feedback_read" do
      it "marks the grade as read by the student" do
        post :feedback_read, params: { id: grade.id }
        expect(grade.reload.feedback_read).to be_truthy
        expect(grade.feedback_read_at).to be_within(1.second).of(Time.now)
        expect(response).to redirect_to assignment_path(assignment)
      end
    end

    describe "protected routes" do
      let(:group) { create :group}

      it "all redirect to root" do
        assignment.groups << group
        [ Proc.new { get :edit, params: { id: grade.id }},
          Proc.new { delete :destroy, params: { id: grade.id }},
        ].each do |protected_route|
          expect(protected_route.call).to redirect_to(:root)
        end
      end
    end
  end

  context "as an observer" do
    let(:observer) { create(:user, courses: [course], role: :observer) }

    before do
      login_user(observer)
      allow(controller).to receive(:current_student).and_return(observer)
    end

    describe "GET show" do
      it "redirects to the assignment show page" do
        expect(get :show, params: { id: grade.id }).to \
          redirect_to(assignment_path(assignment))
      end
    end
  end
end
