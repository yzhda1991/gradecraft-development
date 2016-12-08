require "rails_spec_helper"

describe API::Assignments::SubmissionsController do
  let(:student) { create(:user) }

  before(:each) do
    login_user(student)
  end

  context "with a group assignment" do
    let(:assignment) { create(:group_assignment) }
    let!(:course_membership) { create(:student_course_membership, user: student, course: assignment.course) }
    let!(:assignment_group) { create(:assignment_group, assignment: assignment) }
    let!(:group_membership) { create(:group_membership, student: student, group: assignment_group.group) }
    let(:params) {{ assignment_id: assignment.id }}

    describe "#show" do
      context "when the submission exists" do
        let!(:submission) { create(:submission, assignment: assignment, text_comment_draft: "I love", group_id: assignment_group.group_id) }

        it "returns a 200 ok" do
          get :show, params: params, format: :json
          expect(response.status).to eq(200)
        end
      end

      context "when no submission exists" do
        it "returns a 404 not found" do
          get :show, params: params, format: :json
          expect(response.status).to eq(404)
        end
      end
    end

    describe "#create" do
      let(:submission_attributes) {{ assignment_id: assignment.id, text_comment_draft: "I love school" }}
      let(:params) {{ submission: submission_attributes, assignment_id: assignment.id }}

      context "when successful" do
        it "creates a new submission for the assignment" do
          expect{ post :create, params: params, format: :json }.to change { Submission.count }.by(1)
        end

        it "sets the submission attributes" do
          post :create, params: params, format: :json
          submission = Submission.unscoped.last
          expect(submission.text_comment_draft).to eq(params[:submission][:text_comment_draft])
          expect(submission.student_id).to be_nil
          expect(submission.assignment_id).to eq(submission.assignment_id)
          expect(submission.group_id).to eq(assignment_group.group_id)
        end

        it "returns a 201 created" do
          post :create, params: params, format: :json
          expect(response.status).to eq(201)
        end
      end

      context "when unsuccessful" do
        before(:each) { allow_any_instance_of(Submission).to receive(:save).and_return(false) }

        it "returns a 500 internal server error" do
          post :create, params: params, format: :json
          expect(response.status).to eq(500)
        end
      end
    end
  end

  context "with an individual assignment" do
    let(:assignment) { create(:assignment) }
    let!(:course_membership) { create(:student_course_membership, user: student, course: assignment.course) }

    describe "#show" do
      context "when the submission exists" do
        let!(:submission) { create(:submission, student: student, assignment: assignment, text_comment_draft: "I love") }
        let(:params) {{ assignment_id: assignment.id }}

        it "returns a 200 ok" do
          get :show, params: params, format: :json
          expect(response.status).to eq(200)
        end
      end

      context "when no submission exists" do
        let(:params) {{ assignment_id: assignment.id }}

        it "returns a 404 not found" do
          get :show, params: params, format: :json
          expect(response.status).to eq(404)
        end
      end
    end

    describe "#create" do
      let(:submission_attributes) {{ assignment_id: assignment.id, text_comment_draft: "I love school" }}
      let(:params) {{ submission: submission_attributes, assignment_id: assignment.id }}

      context "when successful" do
        it "creates a new submission for the assignment" do
          expect{ post :create, params: params, format: :json }.to change { Submission.count }.by(1)
        end

        it "sets the submission attributes" do
          post :create, params: params, format: :json
          submission = Submission.unscoped.last
          expect(submission.text_comment_draft).to eq(params[:submission][:text_comment_draft])
          expect(submission.student_id).to eq(student.id)
          expect(submission.assignment_id).to eq(submission.assignment_id)
          expect(submission.group_id).to be_nil
        end

        it "returns a 201 created" do
          post :create, params: params, format: :json
          expect(response.status).to eq(201)
        end
      end

      context "when unsuccessful" do
        before(:each) { allow_any_instance_of(Submission).to receive(:save).and_return(false) }

        it "returns a 500 internal server error" do
          post :create, params: params, format: :json
          expect(response.status).to eq(500)
        end
      end
    end
  end

  describe "#update" do
    let(:assignment) { create(:assignment) }
    let!(:course_membership) { create(:student_course_membership, user: student, course: assignment.course) }
    let(:submission) { create(:submission, student: student, text_comment_draft: "I love school", assignment: assignment) }

    context "when no submission exists" do
      let(:params) {{ submission: submission.as_json, assignment_id: assignment.id, id: "2" }}

      it "returns a 404 not found" do
        put :update, params: params, format: :json
        expect(response.status).to eq(404)
      end
    end

    context "when a submission exists" do
      let(:submission_attributes) {{ id: submission.id, assignment_id: submission.assignment_id,
        student_id: submission.student_id, text_comment_draft: "No really, I love school" }}
      let(:params) {{ submission: submission_attributes, assignment_id: assignment.id, id: submission.id }}

      context "when successful" do
        it "updates the submission text" do
          put :update, params: params, format: :json
          expect(submission.reload.text_comment_draft).to eq(submission_attributes[:text_comment_draft])
        end

        it "returns a 200 ok" do
          put :update, params: params, format: :json
          expect(response.status).to eq(200)
        end
      end

      context "when unsuccessful" do
        before(:each) { allow_any_instance_of(Submission).to receive(:save).and_return(false) }

        it "returns a 500 internal server error" do
          post :create, params: params, format: :json
          expect(response.status).to eq(500)
        end
      end
    end
  end
end
