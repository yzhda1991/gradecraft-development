require 'rails_spec_helper'
require 'active_record_spec_helper'

RSpec.describe SubmissionsExport do
  let(:submissions_export) { SubmissionsExport.new }
  let(:s3_manager) { double(S3Manager::Manager) }
  let(:s3_object_key) { double(:s3_object_key) }

  describe "associations" do
    extend Toolkits::Exports::SubmissionsExportToolkit::Context
    define_association_context

    let(:submissions_export) { create(:submissions_export, submissions_export_associations) }
    subject { submissions_export }

    it "belongs to a course" do
      expect(subject.course).to eq(course)
    end

    it "belongs to a professor" do
      expect(subject.professor).to eq(professor)
    end

    it "belongs to a team" do
      expect(subject.team).to eq(team)
    end

    it "belongs to an assignment" do
      expect(subject.assignment).to eq(assignment)
    end
  end

  describe "#downloadable?" do
    subject { submissions_export.downloadable? }

    context "export has a last_export_completed_at time" do
      it "is downloadable" do
        submissions_export.last_export_completed_at = Time.now
        expect(subject).to be_truthy
      end
    end

    context "export doesn't have a last_export_completed_at time" do
      it "isn't download able" do
        submissions_export.last_export_completed_at = nil
        expect(subject).to be_falsey
      end
    end
  end

  describe "validations" do
    describe "course_id" do
      subject { create(:submissions_export, course: nil) }
      it "requires a course_id" do
        expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    describe "assignment_id" do
      subject { create(:submissions_export, course: nil) }
      it "requires an assignment_id" do
        expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe "#s3_object_key" do
    subject { submissions_export.s3_object_key }

    before do
      allow(submissions_export).to receive_messages(course_id: 40, assignment_id: 50, export_filename: "stuff.zip")
    end

    it "uses the correct object key" do
      expect(subject).to eq("exports/courses/40/assignments/50/stuff.zip")
    end
  end

  describe "#s3_manager" do
    subject { submissions_export.s3_manager }

    it "creates an S3Manager::Manager object" do
      expect(subject.class).to eq(S3Manager::Manager)
    end

    it "caches the S3Manager object" do
      subject
      expect(S3Manager::Manager).not_to receive(:new)
      subject
    end
  end

  describe "#upload_file_to_s3" do
    subject { submissions_export.upload_file_to_s3("great-file.txt") }

    before do
      allow(s3_manager).to receive(:put_encrypted_object) { "some s3 response" }
      allow(submissions_export).to receive(:s3_object_key) { "snake-hat-key" }
      allow(submissions_export).to receive(:s3_manager) { s3_manager }
    end

    it "puts an S3 encrypted object with the object key and file path" do
      expect(s3_manager).to receive(:put_encrypted_object).with("snake-hat-key", "great-file.txt")
      subject
    end

    it "returns the response from the S3 manager" do
      expect(subject).to eq("some s3 response")
    end
  end

  describe "#update_export_completed_time" do
    subject { submissions_export.update_export_completed_time }
    let(:sometime) { Time.parse("Oct 20 1982") }
    before { allow(submissions_export).to receive(:export_time) { sometime } }

    it "calls update_attributes on the submissions export with the export time" do
      expect(submissions_export).to receive(:update_attributes).with(last_export_completed_at: sometime)
      subject
    end

    it "updates the last_export_completed_at timestamp to now" do
      subject
      expect(submissions_export.last_export_completed_at).to eq(sometime)
    end
  end

  describe "#set_s3_attributes" do
    before do
      allow(submissions_export).to receive(:s3_attributes) {{ assignment_id: 98000 }}
    end

    it "sets the submissions export value to the index in the s3_attributes hash" do
      submissions_export.set_s3_attributes
      expect(submissions_export.assignment_id).to eq(98000)
    end
  end

  describe "#s3_object_summary" do
    before do
      allow(submissions_export).to receive_messages(s3_object_key: s3_object_key, s3_manager: s3_manager)
    end

    subject { submissions_export.s3_object_summary }

    it "builds a new object summary with the object key and the s3 manager" do
      expect(S3Manager::Manager::ObjectSummary).to receive(:new).with(s3_object_key, s3_manager)
      subject
    end

    it "returns an ObjectSummary object" do
      expect(subject.class).to eq(S3Manager::Manager::ObjectSummary)
    end

    it "caches the new object summary" do
      subject
      expect(S3Manager::Manager::ObjectSummary).not_to receive(:new)
      subject
    end
  end

  describe "#export_time" do
    it "should return the time now" do
      expect(Time).to receive(:now)
      submissions_export.instance_eval { export_time }
    end
  end

  describe "#s3_attributes" do
    subject { submissions_export.instance_eval { s3_attributes }}

    before do
      allow(submissions_export).to receive_messages(s3_object_key: s3_object_key)
      allow(submissions_export).to receive_message_chain(:s3_manager, :bucket_name) { "dave is home" }
    end

    it "should return a hash with the s3 object key and the s3 bucket name" do
      expect(subject).to eq({s3_object_key: s3_object_key, s3_bucket_name: "dave is home"})
    end
  end
end
