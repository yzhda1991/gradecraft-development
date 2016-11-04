require "rails_spec_helper"

describe API::Assignments::SubmissionsController do
  let(:assignment) { create(:assignment) }
  let(:student)  { create(:student_course_membership, course: assignment.course).user }

  before(:each) do
    login_user(student)
  end

  describe "#create" do
    let(:submission_attributes) { attributes_for(:submission).merge(assignment_id: assignment.id, text_comment: "I love school") }
    let(:params) {{ submission: submission_attributes, assignment_id: assignment.id }}

    context "when successful" do
      it "creates a new submission for the assignment" do
        expect{ post :create, params: params, format: :json }.to change { Submission.count }.by(1)
      end

      it "sets the submission attributes" do
        post :create, params: params, format: :json
        submission = Submission.unscoped.last
        expect(submission.text_comment).to eq params[:submission][:text_comment]
        expect(submission.student_id).to eq student.id
        expect(submission.assignment_id).to eq submission.assignment_id
      end

      it "returns a success status " do
        post :create, params: params, format: :json
        expect(response.status).to eq(201)
      end
    end

    context "when unsuccessful" do
      before(:each) { allow_any_instance_of(Submission).to receive(:save).and_return(false) }

      it "returns an error status" do
        post :create, params: params, format: :json
        expect(response.status).to eq(500)
      end
    end
  end

  describe "#update" do
    let(:submission) { create(:submission, student_id: student.id, text_comment: "I love school", assignment: assignment) }

    context "when the submission doesn't exist" do
      let(:params) {{ submission: submission.as_json, assignment_id: assignment.id, id: "2" }}

      it "returns an error status" do
        put :update, params: params, format: :json
        expect(response.status).to eq(404)
      end
    end

    context "when the submission exists" do
      let(:submission_attributes) {{ id: submission.id, assignment_id: submission.assignment_id, student_id: submission.student_id, text_comment: "No really, I love school" }}
      let(:params) {{ submission: submission_attributes, assignment_id: assignment.id, id: submission.id }}

      context "when successful" do
        it "returns a success status" do
          put :update, params: params, format: :json
          expect(response.status).to eq(200)
        end

        it "updates the submission text" do
          put :update, params: params, format: :json
          expect(submission.reload.text_comment).to eq(submission_attributes[:text_comment])
        end
      end

      context "when unsuccessful" do
        before(:each) { allow_any_instance_of(Submission).to receive(:save).and_return(false) }

        it "returns an error status" do
          post :create, params: params, format: :json
          expect(response.status).to eq(500)
        end
      end
    end
  end
end
