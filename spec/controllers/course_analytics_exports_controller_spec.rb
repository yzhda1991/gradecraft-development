require "rails_spec_helper"

RSpec.describe CourseAnalyticsExportsController, type: :controller do

  let(:course) { create(:course) }
  let(:professor) { create(:professor, course: course) }

  let(:course_analytics_export) do
    create(:course_analytics_export, course: course)
  end

  let(:course_analytics_exports) do
    create_list(:course_analytics_export, 2, course: course)
  end

  let(:presenter_class) { Presenters::CourseAnalyticsExports::Base }

  before do
    login_user professor
    allow(controller).to receive_messages \
      current_course: course,
      current_user: professor,
      presenter: presenter
  end

  describe "POST #create" do
    subject { post :create, course_id: course.id }

    context "the presenter successfully creates and enqueues the export" do
      it "sets the job success flash message" do
        subject
        expect(flash[:success]).to match(/Your course analytics export is being prepared/)
      end
    end

    context "the presenter failes to create and enqueue the export" do
      it "sets the job failure flash message" do
        subject
        expect(flash[:alert]).to match(/Your course analytics export failed to build/)
      end
    end

    it "redirects to the assignment page for the given assignment" do
      subject
      expect(response).to redirect_to(assignment_path(assignment))
    end
  end

  describe "DELETE #destroy" do
    subject { delete :destroy, id: course_analytics_export.id }

    context "the export is successfully destroyed" do
      it "notifies the user of success" do
        allow_any_instance_of(presenter_class).to receive(:destroy_export) { true }
        subject
        expect(flash[:success]).to match(/Assignment export successfully deleted/)
      end
    end

    context "the export is not destroyed" do
      it "notifies the user of the failure" do
        allow_any_instance_of(presenter_class).to receive(:destroy_export) { false }
        subject
        expect(flash[:alert]).to match(/Unable to delete the course analytics export/)
      end
    end

    it "redirects to the exports path" do
      subject
      expect(response).to redirect_to(exports_path)
    end
  end

  describe "GET #download" do
    let(:result) { get :download, id: course_analytics_export.id }

    it "streams the s3 object to the client" do
      expect(controller).to receive(:stream_file_from_s3)
      result
    end
  end

  describe "secure downloads" do
    let(:secure_download_params) do
      {
        secure_token_uuid: secure_token.uuid,
        secret_key: secure_token.random_secret_key,
        id: course_analytics_export.id
      }
    end

    let(:authenticator) { SecureTokenAuthenticator.new authenticator_params }
    let(:authenticator_params) do
      secure_download_params.except(:id).merge(
        target_class: secure_token.target_type,
        target_id: secure_token.target_id
      )
    end

    let(:secure_token) { create(:secure_token, target: course_analytics_export) }

    describe "GET #secure_download" do
      let(:result) { get :secure_download, secure_download_params }

      before(:each) do
        allow(controller).to receive(:secure_download_authenticator)
          .and_return authenticator
      end

      context "the SecureDownloadAuthenticator authenticates" do
        before do
          allow(authenticator).to receive(:authenticates?) { true }
        end

        it "streams the s3 object to the client" do
          expect(controller).to receive(:stream_file_from_s3)
          result
        end
      end

      context "the SecureDownloadAuthenticator doesn't authenticate" do
        before do
          allow(authenticator).to receive(:authenticates?) { false }
        end

        context "the request was for a valid token that has expired" do
          it "alerts the user that their token has expired" do
            allow(authenticator).to receive(:valid_token_expired?) { true }
            result
            expect(flash[:alert]).to match /email link.*expired/
          end
        end

        context "the request completely failed to authenticate" do
          it "alerts the user that their request was invalid" do
            allow(authenticator).to receive(:valid_token_expired?) { false }
            result
            expect(flash[:alert]).to match /does not exist/
          end
        end

        it "redirects the user to the root page and tells them to log in" do
          result
          expect(flash[:alert]).to match /Please login/
          expect(response).to redirect_to root_path
        end
      end

      describe "skipped filters" do
        let(:result) { get :secure_download, secure_download_params }

        before do
          # since we just want to test filter skipping let's disregard the
          # secure token authenticator here
          allow(controller).to receive(:secure_download_authenticator)
            .and_return double(SecureTokenAuthenticator).as_null_object

          # let's disregard s3 file streaming as well
          allow(controller).to receive(:stream_file_from_s3) { false }
        end

        # make the GET secure_download call after each expectation
        after(:each) { result }

        it "doesn't require login" do
          expect(controller).not_to receive(:require_login)
        end

        it "doesn't increment the page views" do
          expect(controller).not_to receive(:increment_page_views)
        end

        it "doesn't get course scores" do
          expect(controller).not_to receive(:course_scores)
        end
      end
    end

    describe "#secure_download_authenticator" do
      let(:result) do
        controller.instance_eval { secure_download_authenticator }
      end

      let(:authenticator_attrs) do
        {
          secure_token_uuid: secure_token.uuid,
          secret_key: secure_token.random_secret_key,
          target_id: course_analytics_export.id,
          target_class: "CourseAnalyticsExport"
        }
      end

      before do
        allow(controller).to receive(:params) { secure_download_params }
      end

      it "builds a new SecureTokenAuthenticator" do
        expect(SecureTokenAuthenticator).to receive(:new)
          .with authenticator_attrs
        result
      end

      it "caches the SecureTokenAuthenticator" do
        result
        expect(SecureTokenAuthenticator).not_to receive(:new)
        result
      end

      it "sets the returned value to @secure_token_authenticator" do
        authenticator = SecureTokenAuthenticator.new authenticator_attrs
        allow(SecureTokenAuthenticator).to receive(:new) { authenticator }
        result
        expect(controller.instance_variable_get(:@secure_download_authenticator))
          .to eq(authenticator)
      end
    end
  end

  describe "#stream_file_from_s3" do
    let(:result) do
      controller.instance_eval { stream_file_from_s3 }
    end
    let(:temp_file) { Tempfile.new("s3_object") }

    before do
      allow(controller).to receive(:course_analytics_export) { course_analytics_export }
      allow(course_analytics_export).to receive_messages(
        export_filename: "some_filename.txt",
        stream_s3_object_body: temp_file
      )
    end

    it "renders the s3 object data with the course analytics export filename" do
      expect(controller).to receive(:send_data).with(temp_file,
        filename: "some_filename.txt")
      result
    end
  end

  describe "#course_analytics_export" do
    subject { controller.instance_eval { course_analytics_export } }
    before { allow(controller).to receive(:params) {{ id: course_analytics_export.id }} }

    it "fetches an course analytics export by id" do
      expect(CourseAnalyticsExport).to receive(:find).with(course_analytics_export.id)
      subject
    end

    it "caches the course analytics export outcome" do
      subject
      expect(CourseAnalyticsExport).not_to receive(:find).with(course_analytics_export.id)
      subject
    end
  end

  describe "#create_course_analytics_export" do
    subject { controller.instance_eval { create_course_analytics_export } }
    let(:course_analytics_export_attrs) {{
      assignment_id: assignment.id,
      course_id: course.id,
      professor_id: professor.id,
      team_id: team.id
    }}

    before do
      allow(controller).to receive(:params) {{ assignment_id: assignment.id, team_id: team.id }}
      allow(controller).to receive_messages(current_course: course, current_user: professor)
    end

    it "creates an course analytics export" do
      expect(CourseAnalyticsExport).to receive(:create).with(course_analytics_export_attrs)
      subject
    end

    it "caches the created course analytics export" do
      subject
      expect(CourseAnalyticsExport).not_to receive(:create)
      subject
    end
  end

  describe "#course_analytics_export_job" do
    subject { controller.instance_eval { course_analytics_export_job } }
    let(:course_analytics_export_job_attrs) {{ course_analytics_export_id: course_analytics_export.id }}

    before do
      controller.instance_variable_set(:@course_analytics_export, course_analytics_export)
    end

    it "instantiates a new course analytics export job" do
      expect(CourseAnalyticsExportJob).to receive(:new).with(course_analytics_export_job_attrs)
      subject
    end

    it "caches the course analytics export job" do
      subject
      expect(CourseAnalyticsExportJob).not_to receive(:new)
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
      expect(Assignment).not_to receive(:find).with(course_analytics_export.id)
      subject
    end
  end
end
