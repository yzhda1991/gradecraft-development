require "active_record_spec_helper"

describe Challenge do
  subject { build(:challenge) }

  describe "validations" do
    it "is invalid without a name" do
      subject.name = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:name]).to include "can't be blank"
    end

    it "is invalid without a course" do
      subject.course = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:course]).to include "can't be blank"
    end
  end
end
