require 'rails_spec_helper'

RSpec.describe AssignmentExportsController, type: :controller do
  describe "GET submissions" do
    before(:each) { get :submissions, assignment_id: 5 }
  end

  describe "GET team_submissions" do
    before(:each) { get :team_submissions }

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
        expect(submissions_response[:status]).to match "Your archive is being prepared."
      end
    end

    context "job was not enqueued" do
      before(:each) { controller_instance.instance_variable_set(:@job_enqueued, false) }

      it "returns an error status" do
        expect(submissions_response[:status]).to eq 400
      end

      it "returns a forboding message" do
        expect(submissions_response[:status]).to match "Your archive failed to build."
      end
    end
  end
end
