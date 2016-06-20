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
  let(:schema_record_set) { { this: "is-the-set" } }

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

    it "has readable parsed_schema_records" do
      expect(subject.parsed_schema_records).to eq schema_record_set
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

      it "uses the parsed_schema_records from the export" do
        allow(export).to receive(:parsed_schema_records) { ["the-records"] }
        expect(subject.parsed_schema_records).to eq ["the-records"]
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

  describe "#csv_filepath" do
    it "joins the path and the filename" do
      allow(subject).to receive_messages \
        path: "/some/path",
        filename: "the-filename.txt"

      expect(subject.csv_filepath).to eq "/some/path/the-filename.txt"
    end
  end

  describe "#generate!" do
    let(:result) { subject.generate! }
    let(:csv_filepath) { Tempfile.new "csv-filepath" }

    before do
      allow(subject).to receive_messages \
        csv_filepath: csv_filepath,
        export_column_names: ["some", "columns"],
        export_rows: [["row1"], ["row2"]]
    end

    it "writes a new csv to the CSV filepath" do
      expect(CSV).to receive(:open).with csv_filepath, "wb"
      result
    end

    it "adds a row of column names from the export schema" do
      result
      expect(CSV.read csv_filepath).to include ["some", "columns"]
    end

    it "adds each of the export rows to the CSV" do
      result
      csv_lines = CSV.read csv_filepath
      expect(csv_lines).to include ["row1"]
      expect(csv_lines).to include ["row2"]
    end
  end

  describe "#export_column_names" do
    it "returns the column names as keys from the export schema hash" do
      expect(subject.export).to receive_message_chain(:class, :schema, :keys)
      subject.export_column_names
    end
  end

  describe "#export_rows" do
    it "returns the transposed rows from the schema records" do
      expect(subject.parsed_schema_records).to receive_message_chain(:values, :transpose)
      subject.export_rows
    end
  end
end
