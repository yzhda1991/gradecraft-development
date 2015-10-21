require "active_record_spec_helper"

describe AssignmentScoreLevel do
  describe "validations" do
    subject { build(:assignment_score_level) }

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
      subject.value = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:value]).to include "can't be blank"
    end
  end
end
