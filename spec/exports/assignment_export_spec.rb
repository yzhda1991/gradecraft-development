require 'rails_spec_helper'
require 'active_record_spec_helper'

RSpec.describe AssignmentExport do
  let(:assignment_export) { AssignmentExport.new }

  describe "associations" do
    extend Toolkits::Exports::AssignmentExportToolkit::Context
    define_association_context

    let(:assignment_export) { create(:assignment_export, assignment_export_associations) }
    subject { assignment_export }

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

  describe "#s3_object_key" do
    subject { assignment_export.s3_object_key }

    before do
      allow(assignment_export).to receive_messages(course_id: 40, assignment_id: 50, export_filename: "stuff.zip")
    end

    it "uses the correct object key" do
      expect(subject).to eq("/exports/courses/40/assignments/50/stuff.zip")
    end
  end

  describe "#s3_manager" do
    subject { assignment_export.s3_manager }

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
    subject { assignment_export.upload_file_to_s3("great-file.txt") }
    let(:s3_manager) { double(S3Manager::Manager) }

    before do
      allow(s3_manager).to receive(:put_encrypted_object) { "some s3 response" }
      allow(assignment_export).to receive(:s3_object_key) { "snake-hat-key" }
      allow(assignment_export).to receive(:s3_manager) { s3_manager }
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
    subject { assignment_export.update_export_completed_time }
    let(:sometime) { Time.parse("Oct 20 1982") }
    before { allow(assignment_export).to receive(:export_time) { sometime } }

    it "calls update_attributes on the assignment export with the export time" do
      expect(assignment_export).to receive(:update_attributes).with(last_export_completed_at: sometime)
      subject
    end

    it "updates the last_export_completed_at timestamp to now" do
      subject
      expect(assignment_export.last_export_completed_at).to eq(sometime)
    end
  end

  describe "#set_s3_attributes" do
    before do
      allow(assignment_export).to receive(:s3_attributes) {{ assignment_id: 98000 }}
    end

    it "sets the assignment export value to the index in the s3_attributes hash" do
      assignment_export.set_s3_attributes
      expect(assignment_export.assignment_id).to eq(98000)
    end
  end

end
