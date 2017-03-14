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
    before do
      allow(subject).to receive_messages({
        export_context: "some context",
        export_classes: "some classes",
        filename: "the_filename.txt",
        directory_name: "ECO500"
      })
    end

    it "builds a new export builder" do
      builder = subject.export_builder
      expect(builder.class).to eq Analytics::Export::Builder
      expect(builder.export_context).to eq "some context"
      expect(builder.export_classes).to eq "some classes"
    end

    it "caches the builder" do
      subject.export_builder
      expect(Analytics::Export::Builder).not_to receive(:new)
      expect(subject.instance_variable_get :@export_builder)
        .to eq subject.export_builder
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
