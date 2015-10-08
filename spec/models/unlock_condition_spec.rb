require "active_record_spec_helper"
require "./app/models/unlock_condition"

describe UnlockCondition do

  subject do
    UnlockCondition.new condition_id: 1, condition_type: "Badge", condition_state: "Earned"
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
end
