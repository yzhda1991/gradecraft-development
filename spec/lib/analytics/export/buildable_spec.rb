require "analytics/export"
require "./spec/support/test_classes/lib/analytics/export/analytics_export_buildable_test"

describe Analytics::Export::Buildable do
  # since this is a module intended for inclusion, let's test a class that's
  # actually using these behaviors
  #
  let(:test_class) { AnalyticsExportBuildableTest }
  subject { test_class.new }

  describe "#build_archive!" do
    it "calls #build_archive! on the export builder" do
      builder = double :builder, build_archive!: "..going.."
      allow(subject).to receive(:export_builder) { builder }
      expect(subject.build_archive!).to eq "..going.."
    end
  end

  describe "#export_builder" do
    let(:builder_attrs) do
      { export_data: "data", export_classes: ["a class"] }
    end

    before do
      allow(subject).to receive(:export_builder_attrs) { builder_attrs }
    end

    it "builds a new export builder" do
      builder = subject.export_builder
      expect(builder.class).to eq Analytics::Export::Builder
      expect(builder.export_data).to eq "data"
      expect(builder.export_classes).to eq ["a class"]
    end

    it "caches the builder" do
      subject.export_builder
      expect(Analytics::Export::Builder).not_to receive(:new)
      expect(subject.instance_variable_get :@export_builder)
        .to eq subject.export_builder
    end
  end

  describe "#export_builder_attrs" do
    it "returns a hash of attributes to use for the builder" do
      allow(subject).to receive_messages \
        export_data: "some data",
        export_classes: "some classes",
        filename: "the_filename.txt",
        directory_name: "ECO500"

      expect(subject.export_builder_attrs).to eq({
        export_data: "some data",
        export_classes: "some classes",
        filename: "the_filename.txt",
        directory_name: "ECO500"
      })
    end
  end

  describe "#upload_builder_archive_to_s3" do
    it "uploads the builder file to s3" do
      allow(subject).to receive(:export_builder)
        .and_return double(:builder, final_export_filepath: "/final/path")

      expect(subject).to receive(:upload_file_to_s3).with "/final/path"
      subject.upload_builder_archive_to_s3
    end
  end
end
