require "analytics/export/record_parser"

describe Analytics::Export::RecordParser do
  subject { described_class.new export: export, records: records }
  let(:export) { double(:export).as_null_object }
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
    it "prints a note on start" do
      expect(subject).to receive(:puts).with " => Generating schema records..."
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
