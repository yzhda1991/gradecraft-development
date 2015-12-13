require "active_record_spec_helper"
require "./app/exporters/assignment_structure_exporter"

describe AssignmentStructureExporter do
  let(:course) { create :course }
  subject { AssignmentStructureExporter.new }

  describe "#assignment_structure(course)" do
    it "generates an empty CSV if there are no assignments" do
      csv = subject.assignment_structure(course)
      expect(csv).to eq "Assignment ID,Name,Point Total,Description,Open At,Due At,Accept Until\n"
    end

    it "generates a csv of assignments if present" do
      assignment = create(:assignment, course: course)

      csv = CSV.new(subject.assignment_structure(course)).read
      expect(csv.length).to eq 2
      expect(csv[1][0]).to eq "#{assignment.id}"
      expect(csv[1][1]).to eq assignment.name
      expect(csv[1][2]).to eq "#{assignment.point_total}"
      expect(csv[1][3]).to eq assignment.description
      expect(csv[1][4]).to eq assignment.open_at
      expect(csv[1][5]).to eq assignment.due_at
      expect(csv[1][6]).to eq assignment.accepts_submissions_until
    end
  end
end
