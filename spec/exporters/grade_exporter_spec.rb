require "active_record_spec_helper"
require "./app/exporters/grade_exporter"

describe GradeExporter do
  let(:assignment) { create(:assignment) }
  let(:students) { create_list :user, 2 }
  subject { GradeExporter.new }

  describe "#export" do
    it "generates an empty CSV if there is no assignment specified" do
      csv = subject.export(nil, [])
      expect(csv).to eq "First Name,Last Name,Email,Score,Feedback\n"
    end

    it "generates an empty CSV if there are no students specified" do
      csv = subject.export(assignment, [])
      expect(csv).to eq "First Name,Last Name,Email,Score,Feedback\n"
    end

    it "generates a CSV with student scores" do
      allow(students[0]).to \
        receive(:grade_for_assignment).with(assignment)
          .and_return double(:grade, score: 123, feedback: nil)
      allow(students[1]).to \
        receive(:grade_for_assignment).with(assignment)
          .and_return double(:grade, score: 456, feedback: "Grrrrreat!")

      csv = CSV.new(subject.export(assignment, students)).read
      expect(csv.length).to eq 3
      expect(csv[1][0]).to eq students[0].first_name
      expect(csv[2][0]).to eq students[1].first_name
      expect(csv[1][1]).to eq students[0].last_name
      expect(csv[2][1]).to eq students[1].last_name
      expect(csv[1][2]).to eq students[0].email
      expect(csv[2][2]).to eq students[1].email
      expect(csv[1][3]).to eq "123"
      expect(csv[2][3]).to eq "456"
      expect(csv[1][4]).to eq ""
      expect(csv[2][4]).to eq "Grrrrreat!"
    end

    it "includes students that do not have grades for the assignment" do
      allow(students[0]).to \
        receive(:grade_for_assignment).with(assignment)
          .and_return nil
      csv = CSV.new(subject.export(assignment, students)).read
      expect(csv[1][3]).to eq ""
    end
  end
end
