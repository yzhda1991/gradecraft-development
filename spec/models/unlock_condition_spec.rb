require "active_record_spec_helper"

describe UnlockCondition do

  let(:badge) { create :badge, name: "fancy name" }
  let(:assignment) { create :assignment, name: "fancier name" }

  subject do
    UnlockCondition.new condition_id: badge.id, condition_type: "Badge", condition_state: "Earned"
  end

  describe "validations" do
    it "requires that a condition id is present" do
      subject.condition_id = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:condition_id]).to include "can't be blank"
    end

    it "requires that a condition type is present" do
      subject.condition_type = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:condition_type]).to include "can't be blank"
    end

    it "requires that a condition state is present" do
      subject.condition_state = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:condition_state]).to include "can't be blank"
    end
  end

  describe "#name" do
    it "returns the name of a badge condition" do
      expect(subject.name).to eq "fancy name"
    end
    
    it "returns the name of an assignment condition" do
      assignment_condition_unlock = UnlockCondition.new condition_id: assignment.id, condition_type: "Assignment", condition_state: "Submitted"
      expect(assignment_condition_unlock.name).to eq "fancier name"
    end
  end
end
