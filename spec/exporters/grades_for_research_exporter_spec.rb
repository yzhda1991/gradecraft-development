require "active_record_spec_helper"
require "./app/exporters/grades_for_research_exporter"

describe GradesForResearchExporter do
  let(:course) { create :course }
  subject { GradesForResearchExporter.new }

  describe "#export" do
    it "generates an empty CSV if there are no students or assignments" do
      csv = subject.research_grades(course)
      expect(csv).to eq "Course ID,Uniqname,First Name,Last Name,GradeCraft ID,Assignment Name,Assignment ID,Assignment Type,Assignment Type Id,Score,Assignment Point Total,Multiplied Score,Predicted Score,Text Feedback,Submission ID,Submission Creation Date,Submission Updated Date,Graded By,Created At,Updated At\n"
    end

    it "generates a CSV with student grades for the course" do
      @student = create(:user)
      @student.courses << course
      @assignment_type = create(:assignment_type, course: course)
      @assignment = create(:assignment, course: course, assignment_type: @assignment_type, name: "Quiz")
      @assignment_2 = create(:assignment, course: course, assignment_type: @assignment_type, name: "Essay")
      @grade = create(:grade, raw_score: 100, course: course, student: @student, assignment: @assignment)
      @grade_2 = create(:grade, raw_score: 200, course: course, student: @student, assignment: @assignment_2)

      csv = CSV.new(subject.research_grades(course)).read
      expect(csv.length).to eq 3
      expect(csv[1][0]).to eq "#{course.id}"
      expect(csv[2][0]).to eq "#{course.id}"
      expect(csv[1][1]).to eq @student.username
      expect(csv[2][1]).to eq @student.username
      expect(csv[1][2]).to eq @student.first_name
      expect(csv[2][2]).to eq @student.first_name
      expect(csv[1][3]).to eq @student.last_name
      expect(csv[2][3]).to eq @student.last_name
      expect(csv[1][4]).to eq "#{@student.id}"
      expect(csv[2][4]).to eq "#{@student.id}"
      expect(csv[1][5]).to eq "Essay"
      expect(csv[2][5]).to eq "Quiz"
      expect(csv[1][6]).to eq "#{@assignment_2.id}"
      expect(csv[2][6]).to eq "#{@assignment.id}"
      expect(csv[1][7]).to eq @assignment_type.name
      expect(csv[2][7]).to eq @assignment_type.name
      expect(csv[1][8]).to eq "#{@assignment_type.id}"
      expect(csv[2][8]).to eq "#{@assignment_type.id}"
      expect(csv[1][9]).to eq "#{@grade_2.raw_score}"
      expect(csv[2][9]).to eq "#{@grade.raw_score}"
      expect(csv[1][10]).to eq "#{@grade_2.point_total}"
      expect(csv[2][10]).to eq "#{@grade.point_total}"
      expect(csv[1][11]).to eq "#{@grade_2.score}"
      expect(csv[2][11]).to eq "#{@grade.score}"
      expect(csv[1][12]).to eq "#{@grade_2.predicted_score}"
      expect(csv[2][12]).to eq "#{@grade.predicted_score}"
      expect(csv[1][13]).to eq "#{@grade_2.feedback}"
      expect(csv[2][13]).to eq "#{@grade.feedback}"
      expect(csv[1][14]).to eq "#{@grade_2.submission_id}"
      expect(csv[2][14]).to eq "#{@grade.submission_id}"
      expect(csv[1][15]).to eq "#{@grade_2.submission.try(:created_at)}"
      expect(csv[2][15]).to eq "#{@grade.submission.try(:created_at)}"
      expect(csv[1][16]).to eq "#{@grade_2.submission.try(:updated_at)}"
      expect(csv[2][16]).to eq "#{@grade.submission.try(:updated_at)}"
      expect(csv[1][17]).to eq "#{@grade_2.graded_by_id}"
      expect(csv[2][17]).to eq "#{@grade.graded_by_id}"
      expect(csv[1][18]).to eq "#{@grade_2.created_at}"
      expect(csv[2][18]).to eq "#{@grade.created_at}"
      expect(csv[1][19]).to eq "#{@grade_2.updated_at}"
      expect(csv[2][19]).to eq "#{@grade.updated_at}"
    end
  end
end
