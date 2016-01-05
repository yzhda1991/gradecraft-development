require 'rails_spec_helper'

RSpec.describe AssignmentExportPerformer, type: :background_job do
  extend Toolkits::Performers::AssignmentExport::Context
  define_context

  subject { performer }

  describe "#setup" do
    subject { performer.setup }
    let(:assignment_export_attributes) {{assignment_export_id: assignment_export.id}}

    before do
      allow(performer).to receive(:assignment_export_attributes) { assignment_export_attributes }
    end

    it "finds the assignment export by id" do
      allow(AssignmentExport).to receive(:find) { double(AssignmentExport).as_null_object }
      expect(AssignmentExport).to receive(:find).with(assignment_export.id)
      subject
    end

    it "fetches the assets" do
      expect(performer).to receive(:fetch_assets)
      subject
    end

    it "creates an assignment export record from the attributes" do
      allow(AssignmentExport).to receive(:find) { assignment_export }
      expect(assignment_export).to receive(:update_attributes)
      subject
    end
    
    it "sets an instance variable for the created assignment export" do
      subject
      expect(performer.instance_variable_get(:@assignment_export)).to eq(assignment_export)
    end
    
    it "creates an empty array for error handling" do
      subject
      expect(performer.instance_variable_get(:@errors)).to eq([])
    end
  end
end
