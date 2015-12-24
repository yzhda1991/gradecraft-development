require 'rails_spec_helper'

RSpec.describe AssignmentExportPerformer, type: :background_job do
  extend Toolkits::Performers::AssignmentExport::Context
  define_context

  subject { performer }

  describe "mailer outcomes" do
    describe "#deliver_outcome_mailer" do
      before(:each) { performer.instance_variable_set(:@check_s3_upload_success, nil) }
      subject { performer.instance_eval { deliver_outcome_mailer }}

      context "the s3 upload is successful" do
        before { allow(performer).to receive(:check_s3_upload_success) { true }}

        it "should deliver the success mailer" do
          expect(performer).to receive(:deliver_archive_success_mailer)
          subject
        end
      end

      context "the s3 upload failed" do
        before { allow(performer).to receive(:check_s3_upload_success) { false }}

        it "should deliver the failure mailer" do
          expect(performer).to receive(:deliver_archive_failed_mailer)
          subject
        end
      end
    end

    describe "#deliver_archive_success_mailer" do
      subject { performer.instance_eval { deliver_archive_success_mailer }}

      context "a @team is present" do
        before { performer.instance_variable_set(:@team, true) }

        it "should deliver the team success mailer" do
          expect(performer).to receive(:deliver_team_export_successful_mailer)
          subject
        end
      end

      context "no @team is present" do
        before { performer.instance_variable_set(:@team, false) }

        it "should deliver the non-team success mailer" do
          expect(performer).to receive(:deliver_export_successful_mailer)
          subject
        end
      end
    end

  end
end
