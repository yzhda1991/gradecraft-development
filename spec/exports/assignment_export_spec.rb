require 'rails_spec_helper'
require 'active_record_spec_helper'

RSpec.describe AssignmentExport do

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
    let(:assignment_export) { AssignmentExport.new }
    subject { assignment_export.s3_object_key }

    before do
      allow(assignment_export).to receive_messages(course_id: 40, assignment_id: 50, export_filename: "stuff.zip")
    end

    it "uses the correct object key" do
      expect(subject).to eq("/exports/courses/40/assignments/50/stuff.zip")
    end
  end
end
