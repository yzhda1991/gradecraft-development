require 'rails_spec_helper'

RSpec.describe AssignmentExportsController, type: :controller do
  let(:professor) { create(:professor_course_membership).user }
  let(:student) { create(:student_course_membership).user }
  let(:assignment_export_job) { AssignmentExportJob.new request_params.merge(professor_id: current_user.id) }
  let(:job_double) { double(AssignmentExportJob).as_null_object }

  describe "GET team_submissions" do
    let(:team_submissions_params) {{ assignment_id: "30", team_id: "20" }}
    let(:team_submissions_job_attributes) { team_submissions_params.merge(professor_id: professor.id) }
    let(:make_request) { get :team_submissions, team_submissions_params }

    before { login_user(professor) }

    describe "building the job" do
      it "instantiates a new assignment export job" do
        make_request
        expect(assigns(:assignment_export_job).class).to eq(AssignmentExportJob)
      end

      it "creates a job with the team submissions attributes" do
        allow(AssignmentExportJob).to receive(:new) { job_double }
        expect(AssignmentExportJob).to receive(:new).with team_submissions_job_attributes
        make_request
      end

      it "enqueues the job" do
        allow(AssignmentExportJob).to receive(:new) { job_double }
        expect(job_double).to receive(:enqueue)
        make_request
      end
    end

    describe "response" do
      let(:imaginary_response) {{ status: 900, json: "the job is totally sweet and enqueued now" }}
      before(:each) do
        allow(controller).to receive(:submissions_response) { imaginary_response }
        make_request
      end

      it "renders the submissions response" do
        expect(response.status).to eq(900)
      end
    end

    describe "authorizations" do
      context"student request" do
        it "redirects the student to the homepage" do
          login_user(student)
          make_request
          expect(response).to redirect_to(root_path)
        end
      end
    end
  end

  describe "GET submissions" do
    let(:submissions_params) {{ assignment_id: 19 }}
    let(:submissions_job_attributes) { submissions_params.merge(professor_id: professor.id) }
    let(:make_request) { get :submissions, submissions_params }

  end

  describe "submissions_response (protected)" do
    let(:controller_instance) { AssignmentExportsController.new }
    let(:submissions_response) { controller_instance.instance_eval { submissions_response }}

    context "job was successfully enqueued" do
      before(:each) { controller_instance.instance_variable_set(:@job_enqueued, true) }

      it "returns an okay status" do
        expect(submissions_response[:status]).to eq 200
      end

      it "returns a pleasant message" do
        expect(submissions_response[:json]).to match "Your archive is being prepared."
      end
    end

    context "job was not enqueued" do
      before(:each) { controller_instance.instance_variable_set(:@job_enqueued, false) }

      it "returns an error status" do
        expect(submissions_response[:status]).to eq 400
      end

      it "returns a forboding message" do
        expect(submissions_response[:json]).to match "Your archive failed to build."
      end
    end
  end
end
