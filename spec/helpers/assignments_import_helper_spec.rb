describe AssignmentsImportHelper do
  subject { helper }

  describe "#date_to_floating_point_seconds" do
    let(:invalid_date) { "a" }
    let(:valid_date) { "11/23/2017 10:22:23 PM" }

    it "returns nil if the due date is unparseable" do
      result = subject.date_to_floating_point_seconds(invalid_date)
      expect(result).to be_nil
    end

    it "returns the due date in number of seconds since the Unix epoch" do
      result = subject.date_to_floating_point_seconds(valid_date)
      expect(result).to be_a_kind_of Float
    end
  end

  describe "#parsed_assignment_type_id" do
    let(:assignment_types) do
      [double(id: 1, name: "Reading"), double(id: 2, name: "Writing")]
    end

    context "when the imported type matches (case-insensitive) an existing type" do
      let(:imported_type) { "reaDing" }

      it "returns the assignment type id" do
        result = subject.parsed_assignment_type_id(assignment_types, imported_type)
        expect(result).to eq 1
      end
    end

    context "when the imported type does not match an existing type" do
      let(:imported_type) { "Some other assignment type" }

      it "returns nil" do
        result = subject.parsed_assignment_type_id(assignment_types, imported_type)
        expect(result).to be_nil
      end
    end
  end
end
