require "active_record_spec_helper"
require "./app/exporters/assignment_exporter"

describe AssignmentExporter do
  let(:assignment) { create(:assignment) }
  let(:students) { create_list :user, 2 }
  subject { AssignmentExporter.new }

  describe "#export" do
    it "generates an empty CSV if there is no assignment specified" do
      csv = subject.export(nil, [])
      expect(csv).to eq "First Name,Last Name,Uniqname,Score,Raw Score,Statement,Feedback,Last Updated\n"
    end

    it "generates an empty CSV if there are no students specified" do
      csv = subject.export(assignment, [])
      expect(csv).to eq "First Name,Last Name,Uniqname,Score,Raw Score,Statement,Feedback,Last Updated\n"
    end

    xit "generates a CSV with student grades for the assignment"
    xit "includes students that do not have grades for the assignment"
    xit "does not include the grade if it has not been graded or released"
  end
end
