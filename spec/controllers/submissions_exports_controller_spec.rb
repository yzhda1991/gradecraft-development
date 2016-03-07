require "rails_spec_helper"

RSpec.describe SubmissionsExportsController, type: :controller do

  let(:teams) { create_list(:team, 2) }
  let(:team) { teams.first }
  let(:course) { create(:course, teams: teams) }
  let(:submissions_exports) { create_list(:submissions_export, 2, course: course, assignment: assignment, s3_object_key: "some thing") }
  let(:submissions_export) { create(:submissions_export, course: course, assignment: assignment, s3_object_key: "some thing") }
  let(:assignment) { create(:assignment) }
  let(:professor) { create(:professor_course_membership, course: course).user }

  before do
    login_user(professor)
    allow(controller).to receive(:current_course) { course }
    allow(controller).to receive(:current_user) { professor }
  end

  describe "POST #create" do
    subject { post :create, assignment_id: assignment.id, team_id: team.id }

    it "creates an submissions export" do
      expect(controller).to receive(:create_submissions_export)
      subject
    end

    describe "enqueuing the submissions export job" do
      context "the submissions export job is enqueued" do
        before { allow(controller).to receive_message_chain(:submissions_export_job, :enqueue) { true } }
        it "sets the job success flash message" do
          subject
          expect(flash[:success]).to match(/Your submissions export is being prepared/)
        end
      end

      context "submissions export job is not enqueued" do
        before { allow(controller).to receive_message_chain(:submissions_export_job, :enqueue) { false } }
        it "sets the job failure flash message" do
          subject
          expect(flash[:alert]).to match(/Your submissions export failed to build/)
        end
      end
    end

    it "redirects to the assignment page for the given assignment" do
      subject
      expect(response).to redirect_to(assignment_path(assignment))
    end
  end

  describe "DELETE #destroy" do
    subject { delete :destroy, id: submissions_export.id }

    before(:each) do
      allow(controller).to receive(:submissions_export) { submissions_export }
    end

    describe "determining success and failure" do
      context "the submissions export is destroyed and the s3 object deleted" do
        before do
          allow(submissions_export).to receive(:delete_object_from_s3) { true }
        end

        it "destroys the submissions export" do
          expect(submissions_export).to receive(:destroy)
          subject
        end

        it "notifies the user of success" do
          subject
          expect(flash[:success]).to match(/Assignment export successfully deleted/)
        end
      end

      context "the submissions export is not destroyed and the s3 object fails to delete" do
        before do
          allow(submissions_export).to receive(:delete_object_from_s3) { false }
        end

        it "notifies the user of the failure" do
          subject
          expect(flash[:alert]).to match(/Unable to delete the submissions export/)
        end
      end
    end

    it "redirects to the exports path" do
      subject
      expect(response).to redirect_to(exports_path)
    end
  end

  describe "GET #download" do
    subject { get :download, id: submissions_export.id }
    let(:s3_object_body) { double("s3 object body").as_null_object }
    let(:export_filename) { "/some/file/name.zip" }

    before do
      allow(controller).to receive_message_chain(:submissions_export, :fetch_object_from_s3, :body, :read) { s3_object_body }
      allow(controller).to receive_message_chain(:submissions_export, :export_filename) { export_filename }
    end

    it "streams the s3 object to the client" do
      expect(controller).to receive(:send_data).with(s3_object_body, filename: export_filename)
      subject
    end
  end

  describe "#submissions_export" do
    subject { controller.instance_eval { submissions_export } }
    before { allow(controller).to receive(:params) {{ id: submissions_export.id }} }

    it "fetches an submissions export by id" do
      expect(SubmissionsExport).to receive(:find).with(submissions_export.id)
      subject
    end

    it "caches the submissions export outcome" do
      subject
      expect(SubmissionsExport).not_to receive(:find).with(submissions_export.id)
      subject
    end
  end

  describe "#create_submissions_export" do
    subject { controller.instance_eval { create_submissions_export } }
    let(:submissions_export_attrs) {{
      assignment_id: assignment.id,
      course_id: course.id,
      professor_id: professor.id,
      team_id: team.id
    }}

    before do
      allow(controller).to receive(:params) {{ assignment_id: assignment.id, team_id: team.id }}
      allow(controller).to receive_messages(current_course: course, current_user: professor)
    end

    it "creates an submissions export" do
      expect(SubmissionsExport).to receive(:create).with(submissions_export_attrs)
      subject
    end

    it "caches the created submissions export" do
      subject
      expect(SubmissionsExport).not_to receive(:create)
      subject
    end
  end

  describe "#submissions_export_job" do
    subject { controller.instance_eval { submissions_export_job } }
    let(:submissions_export_job_attrs) {{ submissions_export_id: submissions_export.id }}

    before do
      controller.instance_variable_set(:@submissions_export, submissions_export)
    end

    it "instantiates a new submissions export job" do
      expect(SubmissionsExportJob).to receive(:new).with(submissions_export_job_attrs)
      subject
    end

    it "caches the submissions export job" do
      subject
      expect(SubmissionsExportJob).not_to receive(:new)
      subject
    end
  end

  describe "#assignment" do
    subject { controller.instance_eval { assignment } }
    before { allow(controller).to receive(:params) {{ assignment_id: assignment.id }} }

    it "fetches an assignment by assignment id" do
      expect(Assignment).to receive(:find).with(assignment.id)
      subject
    end

    it "caches the fetch assignment outcome" do
      subject
      expect(Assignment).not_to receive(:find).with(submissions_export.id)
      subject
    end
  end
end
