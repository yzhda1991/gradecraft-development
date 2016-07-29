require "export"
require "s3_manager"
require "active_record_spec_helper"

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

  describe "#generate_secure_token" do
    it "creates a new secure token with the export data" do
      token = subject.generate_secure_token
      expect(token.class).to eq SecureToken
      expect(token.user_id).to eq subject.professor.id
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
      allow(subject.course).to receive(:courseno) { "some//bad&//courseno" }
      expect(subject.formatted_course_number).to eq "some-badand-courseno"
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
end
