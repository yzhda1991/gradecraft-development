require "active_record_spec_helper"

RSpec.describe SubmissionsExport do
  subject { described_class.new }

  it "includes S3Manager::Rescource" do
    expect(subject).to respond_to :stream_s3_object_body
    expect(subject).to respond_to :rebuild_s3_object_key
  end

  it "includes Export::Model::ActiveRecord" do
    expect(subject).to respond_to :object_key_microseconds
  end

  describe "#s3_object_key_prefix" do
    before do
      allow(subject).to receive_messages \
        object_key_date: "some-date",
        object_key_microseconds: "12345",
        course_id: 99,
        assignment_id: 100
    end

    it "builds a path for the s3 object" do
      expect(subject.s3_object_key_prefix).to eq \
        "exports/courses/99/assignments/100/some-date/12345"
    end
  end

  describe "export_file_basename" do
    let(:result) { subject.instance_eval { export_file_basename }}
    let(:filename_timestamp) { "2020-10-15 - 1230PM" }

    before(:each) do
      subject.instance_variable_set(:@export_file_basename, nil)
      allow(subject).to receive(:archive_basename) { "some_great_submissions" }
      allow(subject).to receive(:filename_timestamp) { filename_timestamp }
    end

    it "includes the fileized_assignment_name" do
      expect(result).to match(/^some_great_submissions/)
    end

    it "is appended with a YYYY-MM-DD formatted timestamp" do
      expect(result).to match(/2020-10-15/)
    end

    it "caches the filename" do
      result
      expect(subject).not_to receive(:archive_basename)
      result
    end

    it "sets the filename to an @export_file_basename" do
      result
      expect(subject.instance_variable_get(:@export_file_basename)).to eq("some_great_submissions - #{filename_timestamp}")
    end
  end

  describe "#filename_timestamp" do
    let(:result) { subject.instance_eval { filename_timestamp }}
    let(:filename_time) { Date.parse("Jan 20 1995").to_time }
    before do
      allow(subject).to receive(:filename_time) { filename_time }
    end

    it "formats the filename time" do
      expect(result).to match(filename_time.strftime("%Y-%m-%d - %l%M%p"))
    end
  end

end
