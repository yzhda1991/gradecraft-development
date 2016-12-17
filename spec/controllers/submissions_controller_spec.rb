require "rails_spec_helper"

describe SubmissionsController do
  let(:course) { create(:course) }
  let(:assignment) { create(:assignment, course: course) }
  let!(:student) { create(:student_course_membership, course: course).user }

  before(:each) do
    session[:course_id] = course.id
    allow(Resque).to receive(:enqueue).and_return(true)
  end

  context "as a professor" do
    let(:professor) { create(:professor_course_membership, course: course).user }
    let(:submission) { create(:submission, assignment: assignment, student: student) }

    before(:each) do
      login_user(professor)
    end

    describe "GET show" do
      let(:ability) { Object.new.extend(CanCan::Ability) }
      let(:make_request) { get :show, params: { id: submission.id, assignment_id: submission.assignment_id }}
      let(:presenter) { double(presenter_class, submission: submission).as_null_object }
      let(:presenter_class) { Submissions::ShowPresenter }

      before do
        allow_any_instance_of(Submissions::ShowPresenter).to receive(:submission)
          .and_return submission
      end

      before(:each) do
        ability.can :read, submission
        allow_any_instance_of(described_class)
          .to receive_messages(
            current_ability: ability,
            presenter: presenter,
            presenter_attrs_with_id: { some: "attrs", id: 5 }
          )
        allow(presenter_class).to receive(:new) { presenter }
      end

      it "returns the submission show page" do
        make_request
        expect(response).to render_template(:show)
      end

      it "builds a show presenter with the presenter attrs" do
        expect(presenter_class).to receive(:new).with({ some: "attrs", id: 5 })
        make_request
      end
    end

    describe "GET new" do
      let(:make_request) { get :new, params: { assignment_id: submission.assignment_id }}
      let(:presenter_class) { Submissions::NewPresenter }

      it "returns the submission new page" do
        make_request
        expect(response).to render_template(:new)
      end
    end

    describe "GET edit" do
      it "display the edit form" do
        get :edit, params: { id: submission.id, assignment_id: assignment.id }
        expect(response).to render_template(:edit)
      end
    end

    describe "POST create" do
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
        params = attributes_for(:submission)
        expect_any_instance_of(Submission).to receive(:check_and_set_late_status!)
        post :create, params: { assignment_id: assignment.id, submission: params }
      end
    end

    describe "POST update" do
      it "updates the submission successfully"  do
        params = attributes_for(:submission)
        params[:assignment_id] = assignment.id
        params[:text_comment] = "Ausgezeichnet"
        post :update, params: { assignment_id: assignment.id, id: submission, submission: params }
        expect(response).to redirect_to(assignment_submission_path(assignment, submission, student_id: student.id))
        expect(submission.reload.text_comment).to eq("Ausgezeichnet")
      end

      it "deletes the text comment draft content" do
        params = attributes_for(:submission)
        expect(Services::DeletesSubmissionDraftContent).to receive(:for).and_call_original
        post :update, params: { assignment_id: assignment.id, id: submission, submission: params }, format: :json
      end

      it "checks if the submission is late" do
        params = attributes_for(:submission)
        expect_any_instance_of(Submission).to receive(:check_and_set_late_status!)
        post :update, params: { assignment_id: assignment.id, id: submission, submission: params }
      end
    end

    describe "GET destroy" do
      let!(:submission) { create(:submission, assignment: assignment, student: student, course: course) }

      it "destroys the submission" do
        expect{ get :destroy, params: { id: submission.id, assignment_id: assignment.id } }.to change(Submission,:count).by(-1)
      end
    end
  end

  context "as a student" do
    let(:delivery) { double(:email, deliver_now: nil) }
    let(:submission) { create(:submission, assignment: assignment, student: student) }

    before do
      login_user(student)
    end

    describe "GET edit" do
      it "shows the edit submission form" do
        get :edit, params: { id: submission.id, assignment_id: assignment.id }
        expect(response).to render_template(:edit)
      end
    end

    describe "POST create" do
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

      it "updates the submission successfully"  do
        params = attributes_for(:submission).merge({ assignment_id: assignment.id })
        params[:text_comment] = "Ausgezeichnet"
        put :update, params: { assignment_id: assignment.id, id: submission, submission: params }
        expect(response).to redirect_to(assignment_path(assignment, anchor: "tab3"))
        expect(submission.reload.text_comment).to eq("Ausgezeichnet")
      end

      it "timestamps the submission" do
        params = attributes_for(:submission).merge({ assignment_id: assignment.id })
        params[:text_comment] = "Ausgezeichnet"
        current_time = DateTime.now
        put :update, params: { assignment_id: assignment.id, id: submission, submission: params }
        expect(submission.reload.submitted_at).to be > current_time
      end

      it "checks if the submission is late" do
        params = attributes_for(:submission).merge({ assignment_id: assignment.id })
        expect_any_instance_of(Submission).to receive(:check_and_set_late_status!)
        post :update, params: { assignment_id: assignment.id, id: submission, submission: params }
      end

      context "with an individual assignment" do
        it "sends a successful email if the submission was a draft" do
          empty_submission = create(:draft_submission, assignment: assignment, student: student)
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
        let(:group_assignment) { create(:group_assignment, course: course) }
        let(:group_submission) { create(:submission, assignment: group_assignment) }

        it "does not send any emails" do
          params = attributes_for(:submission).merge({ assignment_id: group_assignment.id })
          allow_any_instance_of(SubmissionProctor).to receive(:viewable?).and_return true
          expect(NotificationMailer).to_not receive(:updated_submission)
          post :update, params: { assignment_id: group_assignment.id, id: group_submission, submission: params }
        end
      end
    end

    describe "protected routes requiring id in params" do
      [
        :show,
        :destroy
      ].each do |route|
        it "#{route} redirects to root" do
          expect(get route, params: { assignment_id: 1, id: "1" }).to redirect_to(:root)
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
end
