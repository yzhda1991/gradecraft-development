require "analytics"

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

    it "has a readable directory variables" do
      subject.instance_variable_set :@export_tmpdir, "/export/tmp/dir"
      expect(subject.export_tmpdir).to eq "/export/tmp/dir"

      subject.instance_variable_set :@export_root_dir, "/export/root/dir"
      expect(subject.export_root_dir).to eq "/export/root/dir"

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
end
