require "rails_spec_helper"

RSpec.describe SubmissionsExportPerformer, type: :background_job do
  extend Toolkits::Performers::SubmissionsExport::Context
  define_context

  describe "#setup" do
    subject { performer.setup }

    describe "ensuring s3fs parent dir" do
      before(:each) { allow(performer).to receive(:s3fs_tmp_dir_path) { Dir.mktmpdir } }

      context "system is using s3fs" do
        before { allow(performer).to receive(:use_s3fs?) { true } }

        it "ensures that the tmp dir parent exists" do
          expect(performer).to receive(:ensure_s3fs_tmp_dir)
          subject
        end
      end

      context "system is not using s3fs" do
        before { allow(performer).to receive(:use_s3fs?) { false } }
        it "doesn't ensure that the tmp dir parent exists" do
          expect(performer).not_to receive(:ensure_s3fs_tmp_dir)
          subject
        end
      end
    end

    it "finds the submissions export by id" do
      allow(SubmissionsExport).to receive(:find) { create(:submissions_export) }
      expect(SubmissionsExport).to receive(:find).with(submissions_export.id)
      subject
    end

    it "fetches the assets" do
      expect(performer).to receive(:fetch_assets)
      subject
    end

    it "creates an submissions export record from the attributes" do
      allow(SubmissionsExport).to receive(:find) { submissions_export }
      expect(submissions_export).to receive(:update_attributes).at_least(:once)
      subject
    end

    it "sets an instance variable for the created submissions export" do
      subject
      expect(performer.instance_variable_get(:@submissions_export)).to eq(submissions_export)
    end

    it "creates an empty array for error handling" do
      subject
      expect(performer.instance_variable_get(:@errors)).to eq([])
    end
  end
end
