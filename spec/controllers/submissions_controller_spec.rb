describe SubmissionsController do
  let(:course) { build :course }
  let(:assignment) { create :assignment, course: course }
  let(:student) { create :user, courses: [course], role: :student }
  let(:submission) { create :submission, assignment: assignment, course: course, student: student }

  before(:each) { allow(controller).to receive(:current_course).and_return course }

  context "as a professor" do
    let(:professor) { create :user, courses: [course], role: :professor }

    before(:each) { login_user professor }

    describe "GET show" do
      let(:ability) { instance_double "CanCan::Ability", authorize!: true }
      let(:make_request) { get :show, params: { id: submission.id, assignment_id: submission.assignment_id } }
      let(:presenter) { instance_double "Submissions::ShowPresenter", submission: submission }

      before(:each) do
        allow_any_instance_of(described_class)
          .to receive_messages(
            current_ability: ability,
            presenter: presenter,
            presenter_attrs_with_id: { some: "attrs", id: 5 }
          )
        allow(Submissions::ShowPresenter).to receive(:new).and_return presenter
      end

      it "returns the submission show page" do
        make_request
        expect(assigns(:assignment)).to eq assignment
        expect(response).to render_template(:show)
      end
    end

    describe "GET new" do
      let(:make_request) { get :new, params: { assignment_id: submission.assignment_id }}
      let(:presenter) { instance_double "Submissions::NewPresenter", submission: submission, render_options: {} }

      before(:each) { allow(Submissions::NewPresenter).to receive(:new).and_return presenter }

      it "returns the submission new page" do
        make_request
        expect(assigns(:assignment)).to eq assignment
        expect(response).to render_template(:new)
      end
    end

    describe "GET edit" do
      it "display the edit form" do
        allow_any_instance_of(SubmissionProctor).to receive(:open_for_editing?).and_return true
        get :edit, params: { assignment_id: assignment.id,  id: submission.id }
        expect(assigns(:assignment)).to eq assignment
        expect(response).to render_template(:edit)
      end

      it "redirects to the assignment path if the submission is not open for editing" do
        allow_any_instance_of(SubmissionProctor).to receive(:open_for_editing?).and_return false
        get :edit, params: { id: submission.id, assignment_id: assignment.id }
        expect(response).to redirect_to(assignment_path(assignment, anchor: "tabt1"))
      end
    end

    describe "POST create" do
      let!(:grade) { create :grade, assignment: assignment, student_id: student.id, student_visible: true }
      it "assigns the assignment" do
        post :create, params: { assignment_id: assignment.id, submission: attributes_for(:submission) }
        expect(assigns(:assignment)).to eq assignment
      end

      it "creates the submission with valid attributes" do
        params = attributes_for(:submission).merge(student_id: student.id)
        expect{ post :create, params: { assignment_id: assignment.id, submission: params }}.to change(Submission,:count).by(1)
      end

      it "manages submission file uploads" do
        params = attributes_for(:submission).merge(student_id: student.id)
        params.merge! submission_files_attributes: {"0" => {file: [fixture_file("test_file.txt", "txt")]}}
        post :create, params: { assignment_id: assignment.id, submission: params }
        submission = Submission.unscoped.last
        expect(submission.submission_files.count).to eq 1
        expect(submission.submission_files[0].filename).to eq "test_file.txt"
      end

      it "does not create the submission for large files" do
        params = attributes_for(:submission)
        file = fixture_file("test_file.txt", "txt")
        allow_any_instance_of(AttachmentUploader).to receive(:size).and_return 50_000_000
        params.merge! submission_files_attributes: {"0" => {file: [file]}}
        post :create, params: { assignment_id: assignment.id, submission: params }
        expect(response).to render_template :new
      end

      it "checks if the submission is late" do
        params = attributes_for(:submission).merge!(student_id: student.id)
        expect_any_instance_of(Submission).to receive(:check_and_set_late_status!)
        post :create, params: { assignment_id: assignment.id, submission: params }
      end

      it "associates the submission with the grade" do
        params = attributes_for(:submission).merge!(student_id: student.id)
        post :create, params: { assignment_id: assignment.id, submission: params }
        expect(Grade.where(student_id:student.id, assignment_id: assignment.id).first.submission_id).to \
        eq(Submission.where(assignment_id: assignment.id).first.id)
      end
    end

    describe "POST update" do
      let(:submission_params) { attributes_for(:submission) }

      it "assigns the assignment" do
        post :update, params: { assignment_id: assignment.id, id: submission, submission: submission_params }
        expect(assigns(:assignment)).to eq assignment
      end

      it "updates the submission successfully"  do
        submission_params.merge!(assignment_id: assignment.id, text_comment: "Ausgezeichnet")
        post :update, params: { assignment_id: assignment.id, id: submission, submission: submission_params }
        expect(response).to redirect_to(assignment_submission_path(assignment, submission, student_id: student.id))
        expect(submission.reload.text_comment).to eq("Ausgezeichnet")
      end

      it "deletes the text comment draft content" do
        expect(Services::DeletesSubmissionDraftContent).to receive(:for).and_call_original
        post :update, params: { assignment_id: assignment.id, id: submission, submission: submission_params }, format: :json
      end

      it "redirects to the assignments page if the submission is not open for editing" do
        allow_any_instance_of(SubmissionProctor).to receive(:open_for_editing?).and_return false
        post :update, params: { assignment_id: assignment.id, id: submission, submission: submission_params }
        expect(response).to redirect_to(assignment_path(assignment, anchor: "tabt1"))
      end

      it "checks if the submission is late if the submission is not a resubmission" do
        expect_any_instance_of(Submission).to receive(:check_and_set_late_status!)
        post :update, params: { assignment_id: assignment.id, id: submission, submission: submission_params }
      end

      it "does not check if the submission is late if the submission is a resubmission" do
        allow_any_instance_of(Submission).to receive(:will_be_resubmitted?).and_return true
        expect_any_instance_of(Submission).to_not receive(:check_and_set_late_status!)
        post :update, params: { assignment_id: assignment.id, id: submission, submission: submission_params }
      end
    end

    describe "GET destroy" do
      let!(:submission) { create :submission, assignment: assignment, student: student, course: course }

      it "assigns the assignment" do
        delete :destroy, params: { id: submission.id, assignment_id: assignment.id }
        expect(assigns(:assignment)).to eq assignment
      end

      it "destroys the submission" do
        expect{ delete :destroy, params: { id: submission.id, assignment_id: assignment.id } }.to change(Submission,:count).by(-1)
      end
    end
  end

  context "as a student" do
    let(:delivery) { double(:email, deliver_now: nil) }

    before { login_user student }

    describe "GET edit" do
      it "redirects if the assignment is closed" do
        assignment.update open_at: 1.days.from_now
        get :edit, params: { id: submission.id, assignment_id: assignment.id }
        expect(response).to redirect_to assignment_path(assignment)
      end

      it "shows the edit submission form" do
        get :edit, params: { id: submission.id, assignment_id: assignment.id }
        expect(response).to render_template(:edit)
      end

      it "redirects to the assignment path if the submission is not open for editing" do
        allow_any_instance_of(SubmissionProctor).to receive(:open_for_editing?).and_return false
        get :edit, params: { id: submission.id, assignment_id: assignment.id }
        expect(response).to redirect_to(assignment_path(assignment, anchor: "tabt1"))
      end
    end

    describe "POST create" do
      it "redirects if the assignment is closed" do
        assignment.update open_at: 1.days.from_now
        get :edit, params: { id: submission.id, assignment_id: assignment.id }
        expect(response).to redirect_to assignment_path(assignment)
      end

      it "creates the submission with valid attributes" do
        params = attributes_for(:submission, student_id: student.id)
          .merge(assignment_id: assignment.id)
        expect { post :create, params: { assignment_id: assignment.id, submission: params }}.to \
          change(Submission,:count).by(1)
      end

      it "timestamps the submission" do
        params = attributes_for(:submission, student_id: student.id)
          .merge(assignment_id: assignment.id)
        current_time = DateTime.now
        post :create, params: { assignment_id: assignment.id, submission: params }
        submission = Submission.unscoped.last
        expect(submission.submitted_at).to be > current_time
      end

      it "checks if the submission is late" do
        params = attributes_for(:submission, student_id: student.id)
          .merge(assignment_id: assignment.id)
        expect_any_instance_of(Submission).to receive(:check_and_set_late_status!)
        post :create, params: { assignment_id: assignment.id, submission: params }
      end

      it "sends an email if the assigment is individual" do
        params = attributes_for(:submission).merge(student_id: student.id)
        expect(delivery).to receive(:deliver_now)
        expect(NotificationMailer).to \
          receive(:successful_submission).and_return delivery
        post :create, params: { assignment_id: assignment.id, submission: params }
      end
    end

    describe "PUT update" do
      let(:delivery) { double(:email, deliver_now: nil) }

      it "redirects if the assignment is closed" do
        assignment.update open_at: 1.days.from_now
        get :edit, params: { id: submission.id, assignment_id: assignment.id }
        expect(response).to redirect_to assignment_path(assignment)
      end

      it "updates the submission successfully"  do
        params = attributes_for(:submission).merge({ assignment_id: assignment.id })
        params[:text_comment] = "Ausgezeichnet"
        put :update, params: { assignment_id: assignment.id, id: submission, submission: params }
        expect(response).to redirect_to(assignment_path(assignment, anchor: "tabt1"))
        expect(submission.reload.text_comment).to eq("Ausgezeichnet")
      end

      it "timestamps the submission" do
        params = attributes_for(:submission).merge({ assignment_id: assignment.id })
        params[:text_comment] = "Ausgezeichnet"
        current_time = DateTime.now
        put :update, params: { assignment_id: assignment.id, id: submission, submission: params }
        expect(submission.reload.submitted_at).to be > current_time
      end

      it "redirects to the assignments page if the submission is not open for editing" do
        allow_any_instance_of(SubmissionProctor).to receive(:open_for_editing?).and_return false
        post :update, params: { assignment_id: assignment.id, id: submission, submission: attributes_for(:submission) }
        expect(response).to redirect_to(assignment_path(assignment, anchor: "tabt1"))
      end

      it "checks if the submission is late if the submission is not a resubmission" do
        params = attributes_for(:submission).merge({ assignment_id: assignment.id })
        expect_any_instance_of(Submission).to receive(:check_and_set_late_status!)
        post :update, params: { assignment_id: assignment.id, id: submission, submission: params }
      end

      it "does not check if the submission is late if the submission is a resubmission" do
        params = attributes_for(:submission)
        allow_any_instance_of(Submission).to receive(:will_be_resubmitted?).and_return true
        expect_any_instance_of(Submission).to_not receive(:check_and_set_late_status!)
        post :update, params: { assignment_id: assignment.id, id: submission, submission: params }
      end

      context "with an individual assignment" do
        it "sends a successful email if the submission was a draft" do
          empty_submission = create :draft_submission, assignment: assignment, student: student
          submission_params = { course_id: course, assignment_id: assignment.id, student_id: student }
          expect(delivery).to receive(:deliver_now)
          expect(NotificationMailer).to \
            receive(:successful_submission).and_return delivery
          post :update, params: { assignment_id: assignment.id, id: empty_submission.id, submission: submission_params }
        end

        it "sends an updated email if submission was not a draft" do
          params = attributes_for(:submission).merge({ assignment_id: assignment.id })
          allow_any_instance_of(SubmissionProctor).to receive(:viewable?).and_return true
          expect(delivery).to receive(:deliver_now)
          expect(NotificationMailer).to \
            receive(:updated_submission).and_return delivery
          post :update, params: { assignment_id: assignment.id, id: submission, submission: params }
        end
      end

      context "with a group assignment" do
        let(:group_assignment) { create :group_assignment, course: course }
        let(:group_submission) { create :group_submission, assignment: group_assignment }

        it "does not send any emails" do
          params = attributes_for(:submission).merge({ assignment_id: group_assignment.id })
          allow_any_instance_of(SubmissionProctor).to receive(:viewable?).and_return true
          expect(NotificationMailer).to_not receive(:updated_submission)
          post :update, params: { assignment_id: group_assignment.id, id: group_submission, submission: params }
        end
      end
    end

    describe "protected routes" do
      it "redirect with a status 302" do
        [
          -> { get :show, params: { assignment_id: 1, id: 1 } },
          -> { get :destroy, params: { assignment_id: 1, id: 1 } }
        ].each do |protected_route|
          expect(protected_route.call).to have_http_status :redirect
        end
      end
    end

    describe "#presenter_attrs_with_id" do
      before do
        allow(subject).to receive(:base_presenter_attrs) { { base: "attrs" } }
        allow(subject).to receive(:params) { { id: 20 } }
      end

      it "merges the id from params with the base presenter attrs" do
        expect(subject.instance_eval { presenter_attrs_with_id })
          .to eq({ base: "attrs", id: 20 })
      end
    end

    describe "#base_presenter_attrs" do
      before do
        allow(subject).to receive_messages \
          current_course: "some_course",
          view_context: "the view context"

        allow(subject).to receive(:params)
          .and_return({ assignment_id: 40, group_id: 50 })
      end

      it "returns a hash of required params to the presenter" do
        expect(subject.instance_eval { base_presenter_attrs }).to eq({
          assignment_id: 40,
          course: "some_course",
          group_id: 50,
          view_context: "the view context"
        })
      end
    end
  end

  context "as an observer" do
    let(:observer) { build :user, courses: [course], role: :observer }

    before(:each) { login_user observer }

    describe "protected routes" do
      it "redirect with a status 302" do
        [
          -> { get :new, params: { assignment_id: 1 } },
          -> { post :create, params: { assignment_id: 1 } },
          -> { get :edit, params: { assignment_id: 1, id: 1 } },
          -> { get :show, params: { assignment_id: 1, id: 1 } },
          -> { post :update, params: { assignment_id: 1, id: 1 } },
          -> { get :destroy, params: { assignment_id: 1, id: 1 } }
        ].each do |protected_route|
          expect(protected_route.call).to have_http_status :redirect
        end
      end
    end
  end
end
