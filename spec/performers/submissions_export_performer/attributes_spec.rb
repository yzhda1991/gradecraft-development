require 'rails_spec_helper'

RSpec.describe "SubmissionsExport attributes", type: :background_job do
  include PerformerToolkit::SharedExamples
  include Toolkits::Performers::SubmissionsExport::SharedExamples
  include ModelAddons::SharedExamples

  extend Toolkits::Performers::SubmissionsExport::Context
  define_context

  subject { performer }

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
end
