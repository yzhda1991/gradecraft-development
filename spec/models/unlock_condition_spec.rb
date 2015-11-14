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

  describe "#name" do
    it "returns the name of a badge condition" do
      expect(subject.name).to eq "fancy name"
    end
    
    it "returns the name of an assignment condition" do
      assignment_condition_unlock = UnlockCondition.new condition_id: assignment.id, condition_type: "Assignment", condition_state: "Submitted"
      expect(assignment_condition_unlock.name).to eq "fancier name"
    end
  end

  describe "#unlockable_name" do
    it "returns the name of a badge to be unlocked" do
      unlockable_badge_subject = UnlockCondition.new condition_id: badge.id, condition_type: "Badge", condition_state: "Earned", unlockable_id: unlockable_badge.id, unlockable_type: "Badge"
      expect(unlockable_badge_subject.unlockable_name).to eq "unlockable badge"
    end
    
    it "returns the name of an assignment to be unlocked" do
      unlockable_assignment_subject = UnlockCondition.new condition_id: assignment.id, condition_type: "Assignment", condition_state: "Submitted", unlockable_id: unlockable_assignment.id, unlockable_type: "Assignment"
      expect(unlockable_assignment_subject .unlockable_name).to eq "unlockable assignment"
    end
  end

  describe "#is_complete?" do 

    #badge conditions as an unlock 

    it "returns true if the badge has been earned once" do
      student = create(:user)
      student_earned_badge = create(:earned_badge, badge: badge, student: student)
      expect(subject.is_complete?(student)).to eq(true)
    end

    it "returns false if the badge has not been earned" do
      student = create(:user)
      expect(subject.is_complete?(student)).to eq(false)
    end

    it "returns true if the badge has been earned enough times" do 
      student = create(:user)
      student_earned_badge = create(:earned_badge, badge: badge, student: student)
      student_earned_badge_2 = create(:earned_badge, badge: badge, student: student)
      unlock_condition_earned_count = UnlockCondition.new condition_id: badge.id, condition_type: "Badge", condition_state: "Earned", condition_value: 2, unlockable_id: unlockable_assignment.id, unlockable_type: "Assignment"
      expect(unlock_condition_earned_count.is_complete?(student)).to eq(true)
    end

    it "returns false if the badge has been earned enough times" do 
      student = create(:user)
      student_earned_badge = create(:earned_badge, badge: badge, student: student)
      student_earned_badge_2 = create(:earned_badge, badge: badge, student: student)
      unlock_condition_earned_count = UnlockCondition.new condition_id: badge.id, condition_type: "Badge", condition_state: "Earned", condition_value: 3, unlockable_id: unlockable_assignment.id, unlockable_type: "Assignment"
      expect(unlock_condition_earned_count.is_complete?(student)).to eq(false)
    end

    it "returns true if the badge has been earned enough times by a specific date" do
      student = create(:user)
      student_earned_badge = create(:earned_badge, badge: badge, student: student)
      student_earned_badge_2 = create(:earned_badge, badge: badge, student: student)
      unlock_condition_earned_count = UnlockCondition.new condition_id: badge.id, condition_type: "Badge", condition_state: "Earned", condition_value: 2, condition_date: (Date.today + 1), unlockable_id: unlockable_assignment.id, unlockable_type: "Assignment"
      expect(unlock_condition_earned_count.is_complete?(student)).to eq(true)
    end

    it "returns false if the badge has been earned by a specific date but not enough times" do
      student = create(:user)
      student_earned_badge = create(:earned_badge, badge: badge, student: student)
      student_earned_badge_2 = create(:earned_badge, badge: badge, student: student)
      unlock_condition_earned_count = UnlockCondition.new condition_id: badge.id, condition_type: "Badge", condition_state: "Earned", condition_value: 3, condition_date: (Date.today + 1), unlockable_id: unlockable_assignment.id, unlockable_type: "Assignment"
      expect(unlock_condition_earned_count.is_complete?(student)).to eq(false)
    end

    it "returns false if the badge has been earned enough times but not by a specific date" do
      student = create(:user)
      student_earned_badge = create(:earned_badge, badge: badge, student: student)
      student_earned_badge_2 = create(:earned_badge, badge: badge, student: student)
      unlock_condition_earned_count = UnlockCondition.new condition_id: badge.id, condition_type: "Badge", condition_state: "Earned", condition_value: 3, condition_date: (Date.today - 1), unlockable_id: unlockable_assignment.id, unlockable_type: "Assignment"
      expect(unlock_condition_earned_count.is_complete?(student)).to eq(false)
    end

  end

end
