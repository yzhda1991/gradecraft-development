require "active_record_spec_helper"

describe AssignmentType do
  describe "validations" do
    subject { build(:assignment_type) }

    it "is valid with a name" do
      expect(subject).to be_valid
    end

    it "is invalid without a name" do
      subject.name = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:name]).to include "can't be blank"
    end
  end
end
