require "analytics"

describe Analytics::Export::CSV do
  subject do
    described_class.new \
      export: export,
      path: path,
      filename: filename,
      schema_record_set: schema_record_set
  end

  let(:export) { double("FooExport").as_null_object }
  let(:path) { Dir.mktmpdir }
  let(:filename) { "bro.txt" }
  let(:schema_record_set) { ["the-set"] }

  it "has readable attributes" do
    expect(subject.export).to eq export
    expect(subject.path).to eq path
    expect(subject.filename).to eq filename
    expect(subject.schema_records).to eq schema_record_set
  end

  describe "#initialize" do
    context "filename doesn't exist" do
      let(:filename) { nil }

      it "builds a filename from the export class name" do
        allow(export).to receive_message_chain(:class, :name) { "ExportClass" }
        expect(subject.filename).to eq "export_class.csv"
      end
    end
  end
end
