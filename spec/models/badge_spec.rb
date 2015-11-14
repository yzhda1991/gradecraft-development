require "active_record_spec_helper"

describe Badge do
  subject { build(:badge) }

  context "validations" do
    it "is valid with a name and a course" do
      expect(subject).to be_valid
    end

    it "is invalid without a name" do
      subject.name = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:name]).to include "can't be blank"
    end

    it "is invalid without course" do
      subject.course = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:course]).to include "can't be blank"
    end
  end

  describe "#can_earn_multiple_times" do 
    it "is possible by default to earn a badge more than once in a course" do 
      expect(subject.can_earn_multiple_times).to eq(true) 
    end

    it "if so set, it is not possible to earn the badge more than once in a course" do 
      subject.can_earn_multiple_times = false
      expect(subject.can_earn_multiple_times).to eq(false) 
    end
  end

  describe "#awarded_count" do 
    it "returns the count of earned badges that have been awarded" do 
      earned_badge = create(:earned_badge, badge: subject, student_visible: true)
      second_earned_badge = create(:earned_badge, badge: subject, student_visible: true)
      third_earned_badge = create(:earned_badge, badge: subject, student_visible: true)
      expect(subject.awarded_count).to eq(3)
    end

    it "does not include earned badges that are not student visible in the count" do 
      earned_badge = create(:earned_badge, badge: subject, student_visible: false)
      second_earned_badge = create(:earned_badge, badge: subject, student_visible: true)
      third_earned_badge = create(:earned_badge, badge: subject, student_visible: true)
      expect(subject.awarded_count).to eq(2)
    end
  end
  
end