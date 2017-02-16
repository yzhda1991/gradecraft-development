require "spec_helper"
require "grade_proctor"

describe GradesController do
  include PredictorEventJobsToolkit

  let(:course) { create :course }
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
    end

    describe "PUT update" do
      it "updates the grade" do
        put :update, params: { id: grade.id, grade: { raw_points: 12345 }}
        expect(grade.reload.score).to eq(12345)
        expect(response).to redirect_to(assignment_path(grade.assignment))
      end

      it "timestamps the grade" do
        current_time = DateTime.now
        put :update, params: { id: grade.id, grade: { raw_points: 12345 }}
        expect(grade.reload.graded_at).to be > current_time
      end

      it "attaches the student submission" do
        submission = create :submission, assignment: assignment, student: student
        grade_params = { raw_points: 12345, submission_id: submission.id }
        put :update, params: { id: grade.id, grade: grade_params }
        grade = Grade.last
        expect(grade.submission).to eq submission
      end

      it "handles commas in raw score params" do
        put :update, params: { id: grade.id, grade: { raw_points: "12,345" }}
        expect(grade.reload.score).to eq(12345)
      end

      it "handles reverting nil raw score" do
        put :update, params: { id: grade.id, grade: { raw_points: nil }}
        expect(grade.reload.score).to eq(nil)
      end

      it "reverts empty raw score to nil, not zero" do
        put :update, params: { id: grade.id, grade: { raw_points: "" }}
        expect(grade.reload.score).to eq(nil)
      end

      it "updates badges earned on the grade" do
        earned_badge = create :earned_badge, grade: grade, student_visible: false
        put :update, params: { id: grade.id, grade: { status: "Graded" }}
        expect(earned_badge.reload.student_visible).to be_truthy
      end

      context "when grading a series of students" do
        let!(:next_student) do
          create(:course_membership, :student, course: course,
            user: create(:user, last_name: "Zzz")).user
        end

        it "creates and redirects to grade the next ungraded student when not accepting submissions" do
          assignment.update(accepts_submissions: false)
          put :update, params: { id: grade.id, grade: { raw_points: 12345, status: "In Progress"}, redirect_to_next_grade: true}
          expect(response).to redirect_to(edit_grade_path(
            Grade.where(
              student: next_student,
              assignment: assignment).first)
          )
        end

        it "creates and redirects to grade the next student with submission" do
          create :submission, assignment: assignment, student: student
          create :submission, assignment: assignment, student: next_student
          put :update, params: { id: grade.id, grade: { raw_points: 12345 }, redirect_to_next_grade: true}
          expect(response).to redirect_to(edit_grade_path(
            Grade.where(
              student: next_student,
              assignment: assignment).first)
          )
        end

        it "redirects by team when team in params" do
          assignment.update(accepts_submissions: false)
          team = create :team, course: course
          create :team_membership, team: team, student: student
          create :team_membership, team: team, student: next_student
          put :update, params: { id: grade.id, grade: { raw_points: 12345, status: "In Progress"},
                                 redirect_to_next_team_grade: true}
          expect(response).to redirect_to(
            edit_grade_path(
              Grade.where(student: next_student, assignment: assignment).first, team_id: team.id )
          )
        end
      end

      it "redirects on failure" do
        allow_any_instance_of(Grade).to receive(:update_attributes).and_return false
        put :update, params: { id: grade.id, grade: { full_points: 100 }}
        expect(response).to redirect_to(edit_grade_path(grade))
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
          status: "Graded"
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

    describe "POST inlude" do
      before do
        allow_any_instance_of(ScoreRecalculatorJob).to \
          receive(:enqueue).and_return true
      end

      it "marks the Grade as included, and clears the excluded details" do
        grade.update(
          raw_points: 500,
          status: "Graded",
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
          Proc.new { get :update, params: { id: grade.id }},
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
