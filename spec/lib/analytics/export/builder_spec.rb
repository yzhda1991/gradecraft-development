require "analytics"

describe Analytics::Export::Builder do
  subject do
    described_class.new export_data: {}, export_classes: []
  end

  describe "readable attributes" do
    it "has several readable attributes" do
      subject.export_data = "some data"
      expect(subject.export_data).to eq "some data"
    end

    it "has readable export classes" do
      subject.export_classes = ["some classes"]
      expect(subject.export_classes).to eq ["some classes"]
    end

    it "has a readable filename" do
      subject.export_classes = "some_filename.txt"
      expect(subject.export_classes).to eq "some_filename.txt"
    end

    it "has a readable directory_name" do
      subject.export_classes = "some_dirname"
      expect(subject.export_classes).to eq "some_dirname"
    end

    it "has a readable tmp dirs" do
      subject.export_tmpdir = "/export/tmp/dir"
      expect(subject.export_tmpdir).to eq "/export/tmp/dir"

      subject.export_root_dir = "/export/root/dir"
      expect(subject.export_root_dir).to eq "/export/root/dir"

      subject.final_export_tmpdir = "/final/tmp/dir"
      expect(subject.final_export_tmpdir).to eq "/final/tmp/dir"
    end

    it "has a readable completeness" do
      subject.complete = true
      expect(subject.complete).to eq true
    end
  end

end
