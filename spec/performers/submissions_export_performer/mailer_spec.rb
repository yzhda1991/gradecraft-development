require 'rails_spec_helper'

RSpec.describe SubmissionsExportPerformer, type: :background_job do
  extend Toolkits::Performers::SubmissionsExport::Context
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

    describe "#deliver_archive_failed_mailer" do
      subject { performer.instance_eval { deliver_archive_failed_mailer }}

      context "a @team is present" do
        before { performer.instance_variable_set(:@team, true) }

        it "should deliver the team failure mailer" do
          expect(performer).to receive(:deliver_team_export_failure_mailer)
          subject
        end
      end

      context "no @team is present" do
        before { performer.instance_variable_set(:@team, false) }

        it "should deliver the non-team failure mailer" do
          expect(performer).to receive(:deliver_export_failure_mailer)
          subject
        end
      end
    end
  end

  describe "mailer methods" do
    let(:professor) { create(:user) }
    let(:assignment) { create(:assignment) }
    let(:team) { create(:team) }
    let(:submissions_export) { create(:submissions_export) }
    let(:mailer_double) { double('mailer something').as_null_object }

    before(:each) do
      performer.instance_variable_set(:@professor, professor)
      performer.instance_variable_set(:@assignment, assignment)
      performer.instance_variable_set(:@team, team)
      performer.instance_variable_set(:@submissions_export, submissions_export)
      allow(mailer_double).to receive(:deliver_now)
    end

    after(:each) do
      subject
    end

    describe "#deliver_export_successful_mailer" do
      subject { performer.instance_eval { deliver_export_successful_mailer }}
      before(:each) { allow(ExportsMailer).to receive(:submissions_export_success) { mailer_double }}

      it "creates an export success mailer" do
        expect(ExportsMailer).to receive(:submissions_export_success).with(professor, assignment, submissions_export)
      end

      it "delivers the mailer" do
        expect(mailer_double).to receive(:deliver_now)
      end
    end

    describe "#deliver_team_export_successful_mailer" do
      subject { performer.instance_eval { deliver_team_export_successful_mailer }}
      before(:each) { allow(ExportsMailer).to receive(:team_submissions_export_success) { mailer_double }}

      it "delivers a team export success mailer" do
        expect(ExportsMailer).to receive(:team_submissions_export_success).with(professor, assignment, team, submissions_export)
      end

      it "delivers the mailer" do
        expect(mailer_double).to receive(:deliver_now)
      end
    end

    describe "#deliver_export_failure_mailer" do
      subject { performer.instance_eval { deliver_export_failure_mailer }}
      before(:each) { allow(ExportsMailer).to receive(:submissions_export_failure) { mailer_double }}

      it "delivers an export failure mailer" do
        expect(ExportsMailer).to receive(:submissions_export_failure).with(professor, assignment)
      end

      it "delivers the mailer" do
        expect(mailer_double).to receive(:deliver_now)
      end
    end

    describe "#deliver_team_export_failure_mailer" do
      subject { performer.instance_eval { deliver_team_export_failure_mailer }}
      before(:each) { allow(ExportsMailer).to receive(:team_submissions_export_failure) { mailer_double }}

      it "delivers a team export failure mailer" do
        expect(ExportsMailer).to receive(:team_submissions_export_failure).with(professor, assignment, team)
      end

      it "delivers the mailer" do
        expect(mailer_double).to receive(:deliver_now)
      end
    end
  end
end
