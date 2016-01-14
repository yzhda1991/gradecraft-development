require 'rails_spec_helper'

RSpec.describe "SubmissionsExport attributes", type: :background_job do
  include PerformerToolkit::SharedExamples
  include Toolkits::Performers::SubmissionsExport::SharedExamples
  include ModelAddons::SharedExamples

  extend Toolkits::Performers::SubmissionsExport::Context
  define_context

  subject { performer }

  describe "#submissions_export_attributes" do
    subject { performer.submissions_export_attributes }
    before(:each) do
      performer.instance_variable_set(:@submissions_export, submissions_export)
      allow(Time).to receive(:now) { Date.parse("Oct 20 1984").to_time }
    end

    context "the submissions export has been performed at least once" do
      let(:submissions_export) { create(:submissions_export, last_export_started_at: Time.now) }
      it "returns the base export attributes combined with the progress reset attributes" do
        expect(subject).to eq performer.base_export_attributes.merge(performer.clear_progress_attributes)
      end
    end

    context "the submissions export has not been performed yet" do
      let(:submissions_export) { create(:submissions_export, last_export_started_at: nil) }
      it "just returns the base export attributes" do
        expect(subject).to eq performer.base_export_attributes
      end
    end
  end

  describe "#base_export_attributes" do
    before do
      allow(performer).to receive_messages({
        submissions_snapshot: {some: "hash"},
        export_file_basename: "really_bad_file"
      })
    end

    subject { performer.base_export_attributes }
    let(:export_start_time) { Date.parse("Jan 20 1987").to_time }

    it "should include the student ids" do
      expect(subject[:student_ids]).to eq(performer.instance_variable_get(:@students).collect(&:id))
    end

    it "should include the last export started time" do
      allow(Time).to receive(:now) { export_start_time }
      expect(subject[:last_export_started_at]).to eq(export_start_time)
    end

    it "should include the submissions snapshot" do
      expect(subject[:submissions_snapshot]).to eq({some: "hash"})
    end

    it "should include the export filename" do
      expect(subject[:export_filename]).to eq("really_bad_file.zip")
    end
  end

  describe "#clear_progress_attributes" do
    subject { performer.clear_progress_attributes }

    it "returns a list of all progress attributes as nils" do
      expect(subject).to eq({
        generate_export_csv: nil,
        export_csv_successful: nil,
        create_student_directories: nil,
        student_directories_created_successfully: nil,
        create_submission_text_files: nil,
        create_submission_binary_files: nil,
        generate_error_log: nil,
        archive_exported_files: nil,
        upload_archive_to_s3: nil,
        check_s3_upload_success: nil
      })
    end
  end
end
