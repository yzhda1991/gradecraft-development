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
          expect(performer).to receive(:deliver_archive_success_mailer)
          subject
        end
      end
    end

  end
end
