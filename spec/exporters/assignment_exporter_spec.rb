describe AssignmentExporter do
  let(:course) { create(:course) }
  let(:assignment) { create(:assignment, course: course ) }
  subject { AssignmentExporter.new }

  describe "#export(course)" do
    it "generates an empty CSV if there are no assignments" do
      csv = subject.export(course)
      expect(csv).to eq "Assignment ID,Name,Point Total,Description,Open At,Due At,Accept Until,Submissions Count\n"
    end

    it "generates a csv of assignments if present" do
      assignment = create(:assignment, course: course)

      csv = CSV.new(subject.export(course)).read
      expect(csv.length).to eq 2
      expect(csv[1][0]).to eq "#{assignment.id}"
      expect(csv[1][1]).to eq assignment.name
      expect(csv[1][2]).to eq "#{assignment.full_points}"
      expect(csv[1][3]).to eq assignment.description
      expect(csv[1][4]).to eq assignment.open_at
      expect(csv[1][5]).to eq assignment.due_at
      expect(csv[1][6]).to eq assignment.accepts_submissions_until
      expect(csv[1][7]).to eq "#{assignment.submissions.submitted.count}"
    end
  end
end
