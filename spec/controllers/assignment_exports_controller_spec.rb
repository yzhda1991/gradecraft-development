require 'rails_spec_helper'

RSpec.describe AssignmentExportsController, type: :controller do
  let(:assignment) { build(:assignment) }
  let(:team) { build(:team) }
  let(:professor) { build(:user) }
  let(:assignment_export_job) { AssignmentExportJob.new request_params.merge(professor_id: current_user.id) }


  describe "GET team_submissions" do
    let(:request_params) {{ assignment_id: assignment.id, team_id: team.id }}
    before(:each) { get :team_submissions, request_params }

    it "creates a job with the team submissions attributes" do
      expect(AssignmentExportJob).to receive(:new).with team_submissions_attributes
    end

    it "enqueues the job" do
      allow(AssignmentExportJob).to receive(:new) { true }
    end

    describe "response" do
    end

    describe "authorizations" do
      context "staff request" do
        it "processes the request normally" do
        end
      end

      context"student request" do
        it "redirects the student to the homepage" do
        end
      end
    end
  end

  describe "GET submissions" do
    let(:request_params) {{ assignment_id: assignment.id }}
    before(:each) { get :submissions, request_params }

    it "creates a job with the submissions attributes" do
      expect(AssignmentExportJob).to receive(:new).with submissions_attributes
    end

    describe "authorizations" do
      context "staff request" do
        it "processes the request normally" do
        end
      end

      context"student request" do
        it "redirects the student to the homepage" do
        end
      end
    end
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
