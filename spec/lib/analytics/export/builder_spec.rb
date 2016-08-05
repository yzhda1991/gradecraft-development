require "analytics"
require "archive/zip"
require "exports_spec_helper"

describe Analytics::Export::Builder do
  subject do
    described_class.new builder_attrs
  end

  let(:builder_attrs) do
    { export_data: {}, export_classes: [] }
  end

  describe "readable attributes" do
    it "has several readable attributes" do
      subject.instance_variable_set :@export_data, "some data"
      expect(subject.export_data).to eq "some data"
    end

    it "has readable export classes" do
      subject.instance_variable_set :@export_classes, ["some classes"]
      expect(subject.export_classes).to eq ["some classes"]
    end

    it "has a readable filename" do
      subject.instance_variable_set :@filename, "some_filename.txt"
      expect(subject.filename).to eq "some_filename.txt"
    end

    it "has a readable directory_name" do
      subject.instance_variable_set :@directory_name, "some_dirname"
      expect(subject.directory_name).to eq "some_dirname"
    end

    it "has a readable tmpdir" do
      subject.instance_variable_set :@export_tmpdir, "/export/tmp/dir"
      expect(subject.export_tmpdir).to eq "/export/tmp/dir"
    end

    it "has a readable final export tmpdir" do
      subject.instance_variable_set :@final_export_tmpdir, "/final/tmp/dir"
      expect(subject.final_export_tmpdir).to eq "/final/tmp/dir"
    end
  end

  describe "#initialize" do
    it "sets the export_data" do
      expect(subject.export_data).to eq({})
    end

    it "sets the export classes" do
      expect(subject.export_classes).to eq []
    end

    describe "filename" do
      it "sets a filename if there is one" do
        builder = described_class.new builder_attrs.merge(filename: "the-name.txt")
        expect(builder.filename).to eq "the-name.txt"
      end

      it "uses a default filename if none is given" do
        expect(subject.filename).to eq "exported_files.zip"
      end
    end

    describe "directory_name" do
      it "sets a directory_name if one is given" do
        builder = described_class.new builder_attrs.merge(directory_name: "/some/dir")
        expect(builder.directory_name).to eq "/some/dir"
      end

      it "uses a default if none is given" do
        expect(subject.directory_name).to eq "exported_files"
      end
    end
  end

  describe "#build_archive!" do
    before do
      allow(subject).to receive_messages \
        make_directories: true,
        generate_csvs: true,
        build_zip_archive: true
    end

    it "makes the directories" do
      expect(subject).to receive(:make_directories)
      subject.build_archive!
    end

    it "generates the csvs" do
      expect(subject).to receive(:generate_csvs)
      subject.build_archive!
    end

    it "builds the final zip archive" do
      expect(subject).to receive(:build_zip_archive)
      subject.build_archive!
    end
  end

  describe "#make_directories" do
    let(:export_root_dir) { Dir.mktmpdir }

    before(:each) do
      allow(S3fs).to receive(:mktmpdir) { "/s3fs/dir" }
      allow(subject).to receive(:export_root_dir) { export_root_dir }
    end

    it "builds an export_tmpdir" do
      subject.make_directories
      expect(subject.export_tmpdir).to match "/s3fs/dir"
    end

    it "builds a final_export_tmpdir" do
      subject.make_directories
      expect(subject.final_export_tmpdir).to match "/s3fs/dir"
    end

    it "makes a directory for the export_root" do
      expect(FileUtils).to receive(:mkdir_p).with export_root_dir
      subject.make_directories
    end
  end

  describe "#generate_csvs" do
    let(:exporters) do
      (1..2).collect { double(:exporter).as_null_object }
    end

    before do
      allow(subject).to receive_messages \
        exporters: exporters,
        export_root_dir: Dir.mktmpdir
    end

    it "builds an array of exporters with data from the export classes" do
      exporters.each do |exporter|
        expect(exporter).to receive(:generate_csv).with subject.export_root_dir
      end

      subject.generate_csvs
    end
  end

  describe "#exporters" do
    let(:export_classes) { [CourseEventExport, CoursePredictorExport] }
    let(:export_data) { { users: [], assignments: [] } }

    before do
      allow(subject).to receive_messages \
        export_classes: export_classes,
        export_data: export_data,
        export_root_dir: Dir.mktmpdir
    end

    it "builds an array of exporters with data from the export classes" do
      first_export = subject.exporters.first
      expect(first_export.class).to eq export_classes.first
      expect(first_export.data).to eq export_data

      last_export = subject.exporters.last
      expect(last_export.class).to eq export_classes.last
      expect(last_export.data).to eq export_data

      expect(subject.exporters.class).to eq Array
    end

    it "caches the exporters" do
      subject.exporters
      expect(export_classes.first).not_to receive(:new)
      expect(export_classes.last).not_to receive(:new)
      subject.exporters

      expect(subject.instance_variable_get(:@exporters).class).to eq Array
    end
  end

  describe "#build_zip_archive" do
    let(:export_root_dir) { Dir.mktmpdir }
    let(:filepath) { File.join export_root_dir, "test.zip" }

    before do
      allow(subject).to receive_messages \
        export_root_dir: export_root_dir,
        final_export_filepath: filepath
    end

    it "builds an archive from the export root directory" do
      expect(Archive::Zip).to receive(:archive).with(filepath, export_root_dir)
      subject.build_zip_archive
    end

    it "returns the final_export_path on completion" do
      expect(subject.build_zip_archive).to eq filepath
    end
  end

  describe "#final_export_filepath" do
    let(:final_export_tmpdir) { Dir.mktmpdir }

    before do
      allow(subject).to receive_messages \
        final_export_tmpdir: final_export_tmpdir,
        filename: "archive.zip"
    end

    it "returns the absolute path of the final archive file" do
      expect(subject.final_export_filepath).to eq \
        File.join(final_export_tmpdir, "archive.zip")
    end
  end

  describe "#export_root_dir" do
    let(:export_tmpdir) { Dir.mktmpdir }

    before do
      allow(subject).to receive_messages \
        export_tmpdir: export_tmpdir,
        directory_name: "some_dir"
    end

    it "returns the absolute path of the export root directory" do
      expect(subject.export_root_dir).to eq \
        File.join(export_tmpdir, "some_dir")
    end
  end

  describe "#remove_tempdirs" do
    let(:export_root_dir) { Dir.mktmpdir }
    let(:final_export_tmpdir) { Dir.mktmpdir }

    before do
      allow(subject).to receive_messages \
        export_root_dir: export_root_dir,
        final_export_tmpdir: final_export_tmpdir
    end

    it "removes the tmpdirs" do
      expect(Dir.exists? export_root_dir).to eq true
      expect(Dir.exists? final_export_tmpdir).to eq true

      subject.remove_tempdirs
      expect(Dir.exists? export_root_dir).to eq false
      expect(Dir.exists? final_export_tmpdir).to eq false
    end
  end
end
