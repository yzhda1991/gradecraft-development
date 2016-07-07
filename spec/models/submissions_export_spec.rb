require "active_record_spec_helper"

RSpec.describe SubmissionsExport do
  subject { described_class.new }

  it "includes S3Manager::Rescource" do
    expect(subject).to respond_to :stream_s3_object_body
    expect(subject).to respond_to :rebuild_s3_object_key
  end

  it "includes Export::Model::ActiveRecord" do
    expect(subject).to respond_to :created_at_in_microseconds
  end

  describe "#s3_object_key_prefix" do
    before do
      allow(subject).to receive_messages \
        created_at_date: "some-date",
        created_at_in_microseconds: "12345",
        course_id: 99,
        assignment_id: 100
    end

    it "builds a path for the s3 object" do
      expect(subject.s3_object_key_prefix).to eq \
        "exports/courses/99/assignments/100/some-date/12345"
    end
  end
end
