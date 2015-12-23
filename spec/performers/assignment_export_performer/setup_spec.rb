require 'rails_spec_helper'

RSpec.describe AssignmentExportPerformer, type: :background_job do
  extend Toolkits::Performers::AssignmentExport::Context
  define_context

  subject { performer }

  describe "#setup" do
    subject { performer.setup }
    let(:assignment_export_attributes) {{assignment_id: 900}}
    let(:assignment_export_double) { double(AssignmentExport) }

    before do
      allow(performer).to receive(:assignment_export_attributes) { assignment_export_attributes }
    end

    it "should fetch the assets" do
      expect(performer).to receive(:fetch_assets)
      subject
    end

    it "should create an assignment export record from the attributes" do
      expect(AssignmentExport).to receive(:create).with(assignment_export_attributes)
      subject
    end
    
    it "should set an instance variable for the created assignment export" do
      allow(AssignmentExport).to receive(:create) { assignment_export_double }
      subject
      expect(performer.instance_variable_get(:@assignment_export)).to eq(assignment_export_double)
    end
    
    it "should create an empty array for error handling" do
      subject
      expect(performer.instance_variable_get(:@errors)).to eq([])
    end
  end
end
