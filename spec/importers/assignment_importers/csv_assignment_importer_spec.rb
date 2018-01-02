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
          assignment_name: row.assignment_name,
          assignment_type: row.assignment_type,
          point_total: row.point_total,
          description: row.description,
          selected_due_date: row.due_date
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
      expect(assignment.name).to eq assignment_rows.last[:assignment_name]
      expect(assignment.description).to eq assignment_rows.last[:description]
      expect(assignment.full_points).to eq assignment_rows.last[:point_total].to_i
      expect(assignment.due_at).to_not be_nil
      expect(assignment.course).to eq course
    end
  end
end
