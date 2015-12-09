require "active_record_spec_helper"
require "./app/exporters/assignment_exporter"

describe AssignmentExporter do
  let(:assignment) { create(:assignment) }
  let(:students) { create_list :user, 2 }
  subject { AssignmentExporter.new }

  describe "#export" do
    it "generates an empty CSV if there is no assignment specified" do
      csv = subject.export_grades(nil, [])
      expect(csv).to eq "First Name,Last Name,Uniqname,Score,Raw Score,Statement,Feedback,Last Updated\n"
    end

    it "generates an empty CSV if there are no students specified" do
      csv = subject.export_grades(assignment, [])
      expect(csv).to eq "First Name,Last Name,Uniqname,Score,Raw Score,Statement,Feedback,Last Updated\n"
    end

    it "generates a CSV with student grades for the assignment" do
      updated_at = DateTime.now
      allow(students[0]).to \
        receive(:grade_for_assignment).with(assignment)
          .and_return double(:grade, instructor_modified?: true, graded_or_released?: false,
                              score: 123, raw_score: 789, feedback: nil, updated_at: updated_at)
      allow(students[1]).to \
        receive(:grade_for_assignment).with(assignment)
          .and_return double(:grade, instructor_modified?: false, graded_or_released?: true,
                              score: 456, raw_score: 456, feedback: "Grrrrreat!", updated_at: updated_at)
      allow(students[1]).to \
        receive(:submission_for_assignment).with(assignment)
          .and_return double(:submission, text_comment: "Hello there")

      csv = CSV.new(subject.export_grades(assignment, students)).read
      expect(csv.length).to eq 3
      expect(csv[1][0]).to eq students[0].first_name
      expect(csv[2][0]).to eq students[1].first_name
      expect(csv[1][1]).to eq students[0].last_name
      expect(csv[2][1]).to eq students[1].last_name
      expect(csv[1][2]).to eq students[0].username
      expect(csv[2][2]).to eq students[1].username
      expect(csv[1][3]).to eq "123"
      expect(csv[2][3]).to eq "456"
      expect(csv[1][4]).to eq "789"
      expect(csv[2][4]).to eq "456"
      expect(csv[1][5]).to eq ""
      expect(csv[2][5]).to eq "Hello there"
      expect(csv[1][6]).to eq ""
      expect(csv[2][6]).to eq "Grrrrreat!"
      expect(csv[1][7]).to eq "#{updated_at}"
      expect(csv[2][7]).to eq "#{updated_at}"
    end

    it "includes students that do not have grades for the assignment" do
      allow(students[0]).to \
        receive(:grade_for_assignment).with(assignment)
          .and_return nil
      csv = CSV.new(subject.export_grades(assignment, students)).read
      expect(csv[1][3]).to eq ""
    end

    it "does not include the grade if it has not been graded or released" do
      allow(students[0]).to \
        receive(:grade_for_assignment).with(assignment)
          .and_return double(:grade, instructor_modified?: false, graded_or_released?: false)
      csv = CSV.new(subject.export_grades(assignment, students)).read
      expect(csv[1][3]).to eq ""
    end
  end
end
