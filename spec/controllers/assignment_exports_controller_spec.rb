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

  describe "GET #download" do
    subject { get :download, id: assignment_export.id }
    let(:s3_object_body) { double("s3 object body").as_null_object }
    let(:export_filename) { "/some/file/name.zip" }

    before do
      allow(controller).to receive_message_chain(:assignment_export, :fetch_object_from_s3, :body, :read) { s3_object_body }
      allow(controller).to receive_message_chain(:assignment_export, :export_filename) { export_filename }
    end

    it "streams the s3 object to the client" do
      expect(controller).to receive(:send_data).with(s3_object_body, filename: export_filename)
      subject
    end
  end

  describe "#delete_s3_object" do
    subject { controller.instance_eval { delete_s3_object } }
    before { allow(controller).to receive(:assignment_export) { assignment_export } }

    it "calls #delete_object_from_s3 on the assignment export" do
      expect(assignment_export).to receive(:delete_object_from_s3)
      subject
    end

    it "caches the deletion outcome" do
      subject
      expect(assignment_export).not_to receive(:delete_object_from_s3)
      subject
    end
  end

  describe "#assignment_export" do
    subject { controller.instance_eval { assignment_export } }
    before { allow(controller).to receive(:params) {{ id: assignment_export.id }} }

    it "fetches an assignment export by id" do
      expect(AssignmentExport).to receive(:find).with(assignment_export.id)
      subject
    end

    it "caches the deletion outcome" do
      subject
      expect(AssignmentExport).not_to receive(:find).with(assignment_export.id)
      subject
    end
  end

  describe "#create_assignment_export" do
    subject { controller.instance_eval { create_assignment_export } }
    let(:assignment_export_attrs) {{
      assignment_id: assignment.id,
      course_id: course.id,
      professor_id: professor.id,
      team_id: team.id
    }}

    before do
      allow(controller).to receive(:params) {{ assignment_id: assignment.id, team_id: team.id }}
      allow(controller).to receive_messages(current_course: course, current_user: professor)
    end

    it "creates an assignment export" do
      expect(AssignmentExport).to receive(:create).with(assignment_export_attrs)
      subject
    end

    it "caches the created assignment export" do
      subject
      expect(AssignmentExport).not_to receive(:create)
      subject
    end
  end

  describe "#assignment_export_job" do
    subject { controller.instance_eval { assignment_export_job } }
    let(:assignment_export_job_attrs) {{ assignment_export_id: assignment_export.id }}

    before do
      controller.instance_variable_set(:@assignment_export, assignment_export)
    end

    it "instantiates a new assignment export job" do
      expect(AssignmentExportJob).to receive(:new).with(assignment_export_job_attrs)
      subject
    end

    it "caches the assignment export job" do
      subject
      expect(AssignmentExportNew).not_to receive(:new)
      subject
    end
  end
end
