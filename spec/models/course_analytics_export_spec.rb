require "active_record_spec_helper"
require "./app/analytics_exports/course_event_export"
require "./app/analytics_exports/course_predictor_export"
require "./app/analytics_exports/course_user_aggregate_export"
require "./app/analytics_exports/export_contexts/course_export_context"

describe CourseAnalyticsExport do
  subject { create :course_analytics_export, course_id: course.id }
  let(:course) { create :course }

  it "includes S3Manager::Rescource" do
    expect(subject).to respond_to :stream_s3_object_body
    expect(subject).to respond_to :rebuild_s3_object_key
  end

  it "includes Export::Model::ActiveRecord" do
    expect(subject).to respond_to :object_key_microseconds
  end

  it "includes Analytics::Export::Buildable" do
    expect(subject).to respond_to :upload_builder_archive_to_s3
  end

  describe "#generate_secure_token" do
    it "creates a new secure token with the export data" do
      token = subject.generate_secure_token
      expect(token.class).to eq SecureToken
      expect(token.user_id).to eq subject.owner.id
      expect(token.course_id).to eq course.id
      expect(token.target).to eq subject
    end
  end

  describe "#s3_object_key_prefix" do
    before do
      allow(subject).to receive_messages \
        object_key_date: "some-date",
        object_key_microseconds: "12345"
    end

    it "builds a path for the s3 object" do
      expect(subject.s3_object_key_prefix).to eq \
        "exports/courses/#{course.id}/course_analytics_exports/some-date/12345"
    end
  end

  describe "#formatted_course_number" do
    it "formats the course number for use in a url-safe filename" do
      allow(subject.course).to receive(:course_number) { "some//bad&//course_number" }
      expect(subject.formatted_course_number).to eq "some-badand-course_number"
    end
  end

  describe "#url_safe_filename" do
    it "returns a url safe filename" do
      filename_time = Date.parse("jan 8 1998").to_time
      allow(subject).to receive_messages \
        filename_time: filename_time,
        formatted_course_number: "AB200"

      expect(subject.url_safe_filename)
        .to eq "AB200 Analytics Export - 1998-01-08 - 1200AM.zip"
    end
  end

  describe "#export_classes" do
    it "has an array of classes to use for the export" do
      expect(subject.export_classes).to eq \
        [
          CourseEventExport,
          CoursePredictorExport,
          CourseUserAggregateExport
        ]
    end
  end

  describe "#builder_attrs" do
    it "returns a hash of attributes to use for the builder" do
      allow(subject).to receive_messages \
        export_context: "the context",
        export_classes: "some classes",
        url_safe_filename: "the_filename.txt",
        formatted_course_number: "ECO500"

      expect(subject.builder_attrs).to eq({
        export_context: "the context",
        export_classes: "some classes",
        filename: "the_filename.txt",
        directory_name: "ECO500"
      })
    end
  end

  describe "#export_context" do
    it "builds a new CourseExportContext for the export course" do
      expect(subject.export_context.class).to eq CourseExportContext
      expect(subject.export_context.course).to eq subject.course
    end

    it "caches the context instance" do
      subject.export_context
      expect(CourseExportContext).not_to receive(:new)
      expect(subject.instance_variable_get :@export_context)
        .to eq subject.export_context
    end
  end
end
