require "active_record_spec_helper"
require "./app/exporters/assignment_structure_exporter"

describe AssignmentExporter, focus: true do
  let(:course) { create :course }
  subject { AssignmentStructureExporter.new }

  describe "#export" do
    it "generates an empty CSV if there are no assignments" do
      csv = subject.assignment_structure(course)
      expect(csv).to eq "Assignment ID,Name,Point Total,Description,Open At,Due At,Accept Until\n"
    end
  end
end
