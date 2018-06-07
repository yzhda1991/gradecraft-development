describe AssignmentExporter do
  let(:course) { create(:course) }
  let(:assignment) { create(:assignment, course: course ) }
  subject { AssignmentExporter.new }

  describe "#export(course)" do
    it "generates an empty CSV if there are no assignments" do
      csv = subject.export(course)
      expect(csv).to eq "Assignment ID,Name,Assignment Type,Point Total,Description,Assignment Purpose,Open At,Due At,Accepts Submissions,Accept Until,Submissions Count,Grades Count,Created At,Required,Learning Objectives\n"
    end

    it "generates a csv of assignments if present" do
      assignment = create(:assignment, course: course)

      csv = CSV.new(subject.export(course)).read
      expect(csv.length).to eq 2
      expect(csv[1][0]).to  eq "#{assignment.id}"
      expect(csv[1][1]).to  eq assignment.name
      expect(csv[1][2]).to  eq assignment.assignment_type.name
      expect(csv[1][3]).to  eq "#{assignment.full_points}"
      expect(csv[1][4]).to  eq assignment.description
      expect(csv[1][5]).to  eq assignment.purpose
      expect(csv[1][6]).to  eq assignment.open_at
      expect(csv[1][7]).to  eq assignment.due_at
      expect(csv[1][8]).to  eq assignment.accepts_submissions.to_s
      expect(csv[1][9]).to  eq assignment.accepts_submissions_until
      expect(csv[1][10]).to eq "#{assignment.submissions.submitted.count}"
      expect(csv[1][11]).to eq "#{assignment.grades.student_visible.count}"
      expect(csv[1][12]).to eq assignment.created_at.to_formatted_s(:default)
      expect(csv[1][13]).to eq assignment.required.to_s
    end
  end
end
