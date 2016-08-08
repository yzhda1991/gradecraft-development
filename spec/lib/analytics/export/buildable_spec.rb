require "analytics/export"
require "./app/models/course_analytics_export"

describe Analytics::Export::Buildable do
  # since this is a module intended for inclusion, let's test a class that's
  # actually using these behaviors
  #
  describe CourseAnalyticsExport do
    describe "#build_archive!" do
      it "calls #build_archive! on the export builder" do
        builder = double :builder, build_archive!: "..going.."
        allow(subject).to receive(:export_builder) { builder }
        expect(subject.build_archive!).to eq "..going.."
      end
    end

    describe "#export_builder" do
      before do
        allow(subject).to receive_messages \
          export_context: double(:context, export_data: "some data"),
          export_classes: "some classes",
          url_safe_filename: "the_filename.txt",
          formatted_course_number: "ECO500"
      end

      it "builds a new export builder" do
        builder = subject.export_builder
        expect(builder.class).to eq Analytics::Export::Builder
        expect(builder.export_data).to eq "some data"
        expect(builder.export_classes).to eq "some classes"
        expect(builder.filename).to eq "the_filename.txt"
        expect(builder.directory_name).to eq "ECO500"
      end

      it "caches the builder" do
        subject.export_builder
        expect(Analytics::Export::Builder).not_to receive(:new)
        expect(subject.instance_variable_get :@export_builder)
          .to eq subject.export_builder
      end
    end
  end
end
