describe AssignmentScoreLevel do

  let(:assignment) {create :assignment}
  subject { build(:assignment_score_level, assignment: assignment) }

  describe "validations" do

    it "is valid with a name, a value, and an assignment" do
      expect(subject).to be_valid
    end

    it "requires a name" do
      subject.name = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:name]).to include "can't be blank"
    end

    it "requires a valid assignment" do
      subject.assignment.assignment_type_id = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:assignment]).to include "is invalid"
    end

    it "requires a value" do
      subject.points = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:points]).to include "can't be blank"
    end
  end

  describe "#copy" do
    it "creates an identical level" do
      subject.name = "Example Name"
      subject.points = 10
      new_subject = subject.copy
      expect(new_subject.name).to eq("Example Name")
      expect(new_subject.points).to eq(10)
    end
  end
end
