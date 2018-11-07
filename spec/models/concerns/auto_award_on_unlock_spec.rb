describe AutoAwardOnUnlock do
  subject { build :grade }

  let(:unlock_state) { build :unlock_state }
  let(:creates_earned_badge_service) { class_double "Services::CreatesEarnedBadge", call: true }

  before(:each) do
    allow(subject).to receive("Services::CreatesEarnedBadge").and_return \
      creates_earned_badge_service
  end

  describe "#award_badge", focus: true do
    let(:course) { create :course }
    let(:student) { create :user, role: :student, courses: [course] }
    let(:earned_badge_attr) do
      {
        course_id: course.id,
        student_id: student.id
      }
    end

    it "does not award the badge if the unlock state is not unlocked" do
      unlock_state.unlocked = false
      expect(subject.award_badge(unlock_state, earned_badge_attr)).to be_nil
    end

    it "does not award the badge if the unlockable type is not a badge" do
      unlock_state.unlockable_type = "Assignment"
      expect(subject.award_badge(unlock_state, earned_badge_attr)).to be_nil
    end

    it "does not award the badge if the badge does not auto award" do
      unlock_state.unlockable.auto_award_after_unlock = false
      expect(subject.award_badge(unlock_state, earned_badge_attr)).to be_nil
    end

    it "creates an earned badge with auto-awarded feedback" do
      unlock_state.unlocked = true
      unlock_state.unlockable_type = "Badge"
      unlock_state.unlockable.auto_award_after_unlock = true
      expect{ subject.award_badge(unlock_state, earned_badge_attr) }.to change(EarnedBadge, :count).by 1
    end
  end
end
