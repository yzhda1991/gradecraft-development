describe CSVAssignmentImporter do
  subject { described_class.new }

  let(:file) { fixture_file "sample_assignments_import.csv", "text/csv" }

  describe "#as_assignment_rows" do
    it "returns an array of AssignmentRows" do
      result = subject.as_assignment_rows file

      expect(result.length).to eq 4
      expect(result).to all be_a_kind_of CSVAssignmentImporter::AssignmentRow
    end
  end

  describe "#import" do
    let(:course) { create :course }
    let(:assignment_rows) do
      subject.as_assignment_rows(file).map do |row|
        {
          name: row.name,
          assignment_type: row.assignment_type,
          full_points: row.full_points,
          description: row.description,
          purpose: row.purpose,
          selected_open_at: row.open_at,
          selected_due_at: row.due_at,
          required: row.required,
          accepts_submissions: row.accepts_submissions
        }
      end
    end

    before(:each) do
      allow(subject).to receive(:current_course).and_return course
    end

    it "creates the assignment type if it does not exist" do
      expect{ subject.import assignment_rows, course }.to \
        change{ AssignmentType.count }.by 3
    end

    it "creates the assignments" do
      expect{ subject.import assignment_rows, course }.to \
        change{ Assignment.count }.by 4
    end

    it "logs the successful and the unsuccessful rows" do
      subject.import assignment_rows, course
      expect(subject.successful.count).to eq 4
      expect(subject.unsuccessful.count).to be_zero
    end

    it "sets the assignment attributes" do
      subject.import assignment_rows, course

      assignment = Assignment.unscoped.last
      expect(assignment.name).to eq assignment_rows.last[:name]
      expect(assignment.description).to eq assignment_rows.last[:description]
      expect(assignment.accepts_submissions.to_s).to eq assignment_rows.last[:accepts_submissions]
      expect(assignment.required.to_s).to eq assignment_rows.last[:required]
      expect(assignment.purpose).to eq assignment_rows.last[:purpose]
      expect(assignment.full_points).to eq assignment_rows.last[:full_points].to_i
      expect(assignment.open_at).to_not be_nil
      expect(assignment.due_at).to_not be_nil
      expect(assignment.course).to eq course
    end
  end
end
