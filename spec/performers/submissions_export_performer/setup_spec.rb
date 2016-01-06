require 'rails_spec_helper'

RSpec.describe SubmissionsExportPerformer, type: :background_job do
  extend Toolkits::Performers::SubmissionsExport::Context
  define_context

  subject { performer }

  describe "#setup" do
    subject { performer.setup }
    let(:submissions_export_attributes) {{submissions_export_id: submissions_export.id}}

    before do
      allow(performer).to receive(:submissions_export_attributes) { submissions_export_attributes }
    end

    it "finds the assignment export by id" do
      allow(SubmissionsExport).to receive(:find) { double(SubmissionsExport).as_null_object }
      expect(SubmissionsExport).to receive(:find).with(submissions_export.id)
      subject
    end

    it "fetches the assets" do
      expect(performer).to receive(:fetch_assets)
      subject
    end

    it "creates an assignment export record from the attributes" do
      allow(SubmissionsExport).to receive(:find) { submissions_export }
      expect(submissions_export).to receive(:update_attributes)
      subject
    end
    
    it "sets an instance variable for the created assignment export" do
      subject
      expect(performer.instance_variable_get(:@submissions_export)).to eq(submissions_export)
    end
    
    it "creates an empty array for error handling" do
      subject
      expect(performer.instance_variable_get(:@errors)).to eq([])
    end
  end
end
