describe AssignmentExporter do
  let(:course) { create(:course) }
  let(:user) { build_stubbed :user }
  let(:assignment) { create(:assignment, course: course ) }
  subject { AssignmentExporter.new user, course }

  describe "#export(course)" do
    it "generates an empty CSV if there are no assignments" do
      csv = subject.export
      expect(csv).to eq "Name,Assignment Type,Point Total,Description,Purpose,Open At,Due At,Accepts Submissions,Accept Until,Required,Assignment Id,Created At,Submissions Count,Grades Count,Learning Objectives\n"
    end

    it "returns the header list for alignment with import" do
      expect(AssignmentExporter::FORMAT).to eq(
        ["Name", "Assignment Type", "Point Total", "Description", "Purpose", "Open At", "Due At", "Accepts Submissions", "Accept Until", "Required"]
      )
    end

    it "generates a csv of assignments if present" do
      assignment = create(:assignment, course: course)

      csv = CSV.new(subject.export).read
      expect(csv.length).to eq 2
      expect(csv[1][0]).to eq assignment.name
      expect(csv[1][1]).to eq assignment.assignment_type.name
      expect(csv[1][2]).to eq "#{assignment.full_points}"
      expect(csv[1][3]).to eq assignment.description
      expect(csv[1][4]).to eq assignment.purpose
      expect(csv[1][5]).to eq assignment.open_at
      expect(csv[1][6]).to eq assignment.due_at
      expect(csv[1][7]).to eq assignment.accepts_submissions.to_s
      expect(csv[1][8]).to eq assignment.accepts_submissions_until
      expect(csv[1][9]).to eq assignment.required.to_s
    end
  end
end
