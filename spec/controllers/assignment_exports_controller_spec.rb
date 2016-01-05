require 'rails_spec_helper'

RSpec.describe AssignmentExportsController, type: :controller do

  let(:teams) { create_list(:team, 2) }
  let(:course) { create(:course, teams: teams) }
  let(:assignment_exports) { create_list(:assignment_export, 2, course: course, assignment: assignment) }
  let(:assignment) { create(:assignment) }
  let(:professor) { create(:professor_course_membership, course: course).user }

  before do
    login_user(professor)
    allow(controller).to receive(:current_course) { course }
  end

  describe "POST #create" do
    it "creates an assignment export" do
      expect(controller).to receive(:create_assignment_export)
      post :create
    end

    describe "enqueuing the assignment export job" do
      context "the assignment export job is enqueued" do
        before { allow(:controller).to receive_message_chain(:assignment_export_job, :enqueue) { true } }
        it "sets the job success flash message" do
          expect(controller).to receive(:job_success_flash)
          post :create
        end
      end

      context "assignment export job is not enqueued" do
        before { allow(:controller).to receive_message_chain(:assignment_export_job, :enqueue) { false } }
        it "sets the job failure flash message" do
          expect(controller).to receive(:job_failure_flash)
          post :create
        end
      end
    end

    it "redirects to the assignment page for the given assignment" do
      expect(controller).to redirect_to(assignment_path(assignment))
      post :create
    end
  end

end
