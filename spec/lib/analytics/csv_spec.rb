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

  describe "readable attributes" do
    it "has a readable export" do
      expect(subject.export).to eq export
    end

    it "has a readable path" do
      expect(subject.path).to eq path
    end

    it "has a readable filename" do
      expect(subject.filename).to eq filename
    end

    it "has readable schema_records" do
      expect(subject.schema_records).to eq schema_record_set
    end
  end

  describe "#initialize" do
    context "filename doesn't exist" do
      let(:filename) { nil }

      it "builds a filename from the export class name" do
        allow(export).to receive_message_chain(:class, :name) { "ExportClass" }
        expect(subject.filename).to eq "export_class.csv"
      end
    end

    context "schema_record_set doesn't exist" do
      let(:schema_record_set) { nil }

      it "uses the schema_records from the export" do
        allow(export).to receive(:schema_records) { ["the-records"] }
        expect(subject.schema_records).to eq ["the-records"]
      end
    end

    context "a directory already exists at the 'path'" do
      it "doesn't create the path" do
        path # cache the path to make the tmpdir
        expect(FileUtils).not_to receive(:mkdir_p).with path
        subject
      end
    end

    context "no directory exists at the designated 'path'" do
      it "creates a directory at the path" do
        path # cache the path to make the tempdir
        FileUtils.rmdir path # get rid of the directory
        expect(FileUtils).to receive(:mkdir_p).with path
        subject
      end
    end
  end
end
