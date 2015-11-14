require "active_record_spec_helper"

describe UnlockCondition do

  let(:badge) { create :badge, name: "fancy name" }
  let(:unlockable_badge) { create :badge, name: "unlockable badge" }
  let(:assignment) { create :assignment, name: "fancier name" }
  let(:unlockable_assignment) { create :assignment, name: "unlockable assignment" }

  subject do
    UnlockCondition.new condition_id: badge.id, condition_type: "Badge", condition_state: "Earned", unlockable_id: unlockable_assignment.id, unlockable_type: "Assignment"
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

  describe "#name", focus: true do
    it "returns the name of a badge condition" do
      expect(subject.name).to eq "fancy name"
    end
    
    it "returns the name of an assignment condition" do
      assignment_condition_unlock = UnlockCondition.new condition_id: assignment.id, condition_type: "Assignment", condition_state: "Submitted"
      expect(assignment_condition_unlock.name).to eq "fancier name"
    end
  end

  describe "#unlockable_name", focus: true do
    it "returns the name of a badge to be unlocked" do
      unlockable_badge_subject = UnlockCondition.new condition_id: badge.id, condition_type: "Badge", condition_state: "Earned", unlockable_id: unlockable_badge.id, unlockable_type: "Badge"
      expect(unlockable_badge_subject.unlockable_name).to eq "unlockable badge"
    end
    
    it "returns the name of an assignment to be unlocked" do
      unlockable_assignment_subject = UnlockCondition.new condition_id: assignment.id, condition_type: "Assignment", condition_state: "Submitted", unlockable_id: unlockable_assignment.id, unlockable_type: "Assignment"
      expect(unlockable_assignment_subject .unlockable_name).to eq "unlockable assignment"
    end
  end
end
