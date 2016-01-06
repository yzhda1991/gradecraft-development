require 'rails_spec_helper'

RSpec.describe AssignmentExportsController, type: :controller do

  let(:teams) { create_list(:team, 2) }
  let(:team) { teams.first }
  let(:course) { create(:course, teams: teams) }
  let(:assignment_exports) { create_list(:assignment_export, 2, course: course, assignment: assignment) }
  let(:assignment_export) { create(:assignment_export, course: course, assignment: assignment) }
  let(:assignment) { create(:assignment) }
  let(:professor) { create(:professor_course_membership, course: course).user }

  before do
    login_user(professor)
    allow(controller).to receive(:current_course) { course }
    allow(controller).to receive(:current_user) { professor }
  end

  describe "POST #create" do
    subject { post :create, assignment_id: assignment.id, team_id: team.id }

    it "creates an assignment export" do
      expect(controller).to receive(:create_assignment_export)
      subject
    end

    describe "enqueuing the assignment export job" do
      context "the assignment export job is enqueued" do
        before { allow(controller).to receive_message_chain(:assignment_export_job, :enqueue) { true } }
        it "sets the job success flash message" do
          expect(controller).to receive(:job_success_flash)
          subject
        end
      end

      context "assignment export job is not enqueued" do
        before { allow(controller).to receive_message_chain(:assignment_export_job, :enqueue) { false } }
        it "sets the job failure flash message" do
          expect(controller).to receive(:job_failure_flash)
          subject
        end
      end
    end

    it "redirects to the assignment page for the given assignment" do
      subject
      expect(response).to redirect_to(assignment_path(assignment))
    end
  end

  describe "DELETE #destroy" do
    subject { delete :destroy, id: assignment_export.id }

    it "deletes the corresponding s3 object for the assignment export" do
      expect(controller).to receive(:delete_s3_object)
      subject
    end


    describe "determining success and failure" do
      context "the assignment export is destroyed and the s3 object deleted" do
        before do
          allow(controller).to receive(:delete_s3_object) { true }
        end

        it "destroys the assignment export" do
          allow(AssignmentExport).to receive(:find) { assignment_export }
          expect(assignment_export).to receive(:destroy)
          subject
        end

        it "notifies the user of success" do
          subject
          expect(flash[:success]).to match(/Assignment export successfully deleted/)
        end
      end

      context "the assignment export is not destroyed and the s3 object fails to delete" do
        before do
          allow(controller).to receive(:delete_s3_object) { false }
        end

        it "notifies the user of the failure" do
          subject
          expect(flash[:alert]).to match(/Unable to delete the assignment export/)
        end
      end
    end

    it "redirects to the exports path" do
      subject
      expect(response).to redirect_to(exports_path)
    end
  end


end
