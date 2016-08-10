require "analytics/export/parsers"
require "./spec/support/test_classes/lib/analytics/analytics_export_model_test"

describe Analytics::Export::Parsers::Column do
  subject { described_class.new export: export, records: records }
  let(:export) { AnalyticsExportModelTest.new loaded: "data" }
  let(:records) { [{ id: 1 }, { id: 2 }] }

  describe "readable attributes" do
    it "has a readable export" do
      expect(subject.export).to eq export
    end

    it "has readable records" do
      expect(subject.records).to eq records
    end
  end

  describe "#initialize" do
    it "sets the export" do
      expect(subject.instance_variable_get(:@export)).to eq export
    end

    it "sets the records" do
      expect(subject.instance_variable_get(:@records)).to eq records
    end
  end

  describe "#parse_records!" do
    it "prints some notes about the progress" do
      expect(subject).to receive(:puts).with " => Generating schema records..."
      expect(subject).to receive(:puts).with "    => column :dinosaurs, row :waffles"

      subject.parse_records!
    end
  end

  describe "#schema" do
    it "gets the schema from the export class" do
      expect(subject.export).to receive_message_chain(:class, :schema)
      subject.schema
    end
  end
end
