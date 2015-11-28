require "active_record_spec_helper"
require "./app/exporters/assignment_type_exporter"

describe AssignmentTypeExporter do
  let(:course) { create :course }
  let(:students) { create_list :user, 2 }
  subject { AssignmentTypeExporter.new }

  describe "#export_summary_scores" do

    it "generates an empty CSV if there are no students specified" do
      assignment_type_1 = create(:assignment_type, course: course, name: "Charms")
      assignment_type_2 = create(:assignment_type, course: course, name: "History of Wizardry")
      assignment_types = course.assignment_types
      csv = subject.export_summary_scores(assignment_types, course, [])
      expect(csv).to include 'First Name,Last Name,Email,Username,Team,Charms,History of Wizardry'
    end

  end

  describe "#export_scores" do 
    it "generates an empty CSV if there are no students specified" do
      assignment_type_1 = create(:assignment_type, course: course, name: "Charms")
      assignment_type_2 = create(:assignment_type, course: course, name: "History of Wizardry")
      assignment_types = course.assignment_types
      csv = subject.export_scores(assignment_types, course, [])
      expect(csv).to include 'First Name,Last Name,Email,Username,Team,Raw Score,Score'
    end
  end
end