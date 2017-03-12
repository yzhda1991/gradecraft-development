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

    it "is invalid without a visible state" do
      subject.visible = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:visible]).to include "must be true or false"
    end

    it "is invalid without a can_earn_multiple_times state" do
      subject.can_earn_multiple_times = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:can_earn_multiple_times]).to include "must be true or false"
    end

    it "is invalid without a visible_when_locked state" do
      subject.visible_when_locked = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:visible_when_locked]).to include "must be true or false"
    end

    it "is invalid without a show_name_when_locked state" do
      subject.show_name_when_locked = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:show_name_when_locked]).to include "must be true or false"
    end

    it "is invalid without a show_points_when_locked state" do
      subject.show_points_when_locked = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:show_points_when_locked]).to include "must be true or false"
    end

    it "is invalid without a show_description_when_locked state" do
      subject.show_description_when_locked = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:show_description_when_locked]).to include "must be true or false"
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

  describe "#earned_count" do
    it "returns the count of earned badges that have been awarded" do
      earned_badge = create(:earned_badge, badge: subject)
      second_earned_badge = create(:earned_badge, badge: subject)
      third_earned_badge = create(:earned_badge, badge: subject)
      expect(subject.earned_count).to eq(3)
    end

    it "does not include earned badges that are not student visible in the count" do
      earned_badge_not_visible = create(:earned_badge, badge: subject, grade: create(:unreleased_grade))
      second_earned_badge = create(:earned_badge, badge: subject)
      third_earned_badge = create(:earned_badge, badge: subject)
      expect(subject.earned_count).to eq(2)
    end
  end

  describe "#copy" do
    let(:badge) { build :badge }
    subject { badge.copy }

    it "makes a duplicated copy of itself" do
      expect(subject).to_not eq badge
    end
  end

  describe "#is_a_condition?" do
    it "returns true if the badge is an unlock condition" do
      badge = create(:badge)
      unlock_condition = create(:unlock_condition, condition_id: badge.id, condition_type: "Badge", condition_state: "Earned")
      expect(badge.is_a_condition?).to eq(true)
    end

    it "returns false if the badge is an unlockable" do
      badge = create(:badge)
      second_badge = create(:badge)
      unlock_condition = create(:unlock_condition, condition_id: second_badge.id, condition_type: "Badge", condition_state: "Earned", unlockable_id: badge.id, unlockable_type: "Badge")
      expect(badge.is_a_condition?).to eq(false)
    end
  end

  describe "#is_unlockable?" do
    it "returns true if the badge is an unlockable" do
      badge = create(:badge)
      second_badge = create(:badge)
      unlock_condition = create(:unlock_condition, condition_id: second_badge.id, condition_type: "Badge", condition_state: "Earned", unlockable_id: badge.id, unlockable_type: "Badge")
      expect(badge.is_unlockable?).to eq(true)
    end

    it "returns false if the badge is a condition" do
      badge = create(:badge)
      second_badge = create(:badge)
      unlock_condition = create(:unlock_condition, condition_id: badge.id, condition_type: "Badge", condition_state: "Earned", unlockable_id: second_badge.id, unlockable_type: "Badge")
      expect(badge.is_unlockable?).to eq(false)
    end
  end

  describe "#unlockable" do
    it "returns the unlockable object from a condition" do
      badge = create(:badge)
      second_badge = create(:badge)
      unlock_condition = create(:unlock_condition, condition_id: second_badge.id, condition_type: "Badge", condition_state: "Earned", unlockable_id: badge.id, unlockable_type: "Badge")
      expect(second_badge.unlockable).to eq(badge)
    end
  end

  describe "#is_unlocked_for_student?(student)" do
    it "returns true if a student has met the necessary requirements to unlock the badge" do
      locked_badge = create(:badge)
      badge = create(:badge)
      assignment = create(:assignment)
      student = create(:user)
      unlock_condition = create(:unlock_condition, unlockable_id: locked_badge.id, unlockable_type: "Badge", condition_id: assignment.id, condition_type: "Assignment", condition_state: "Submitted")
      unlock_condition_2 = create(:unlock_condition, unlockable_id: locked_badge.id, unlockable_type: "Badge", condition_id: badge.id, condition_type: "Badge", condition_state: "Earned", condition_value: 2)
      submission = create(:submission, student: student, assignment: assignment)
      earned_badge = create(:earned_badge, badge: badge, student: student)
      earned_badge_2 = create(:earned_badge, badge: badge, student: student)
      expect(locked_badge.is_unlocked_for_student?(student)).to eq(true)
    end

    it "returns false if a student has not met the necessary requirements to unlock the badge" do
      locked_badge = create(:badge)
      badge = create(:badge)
      assignment = create(:assignment)
      student = create(:user)
      unlock_condition = create(:unlock_condition, unlockable_id: locked_badge.id, unlockable_type: "Badge", condition_id: assignment.id, condition_type: "Assignment", condition_state: "Submitted")
      unlock_condition_2 = create(:unlock_condition, unlockable_id: locked_badge.id, unlockable_type: "Badge", condition_id: badge.id, condition_type: "Badge", condition_state: "Earned", condition_value: 2)
      submission = create(:submission, student: student, assignment: assignment)
      earned_badge = create(:earned_badge, badge: badge, student: student)
      expect(locked_badge.is_unlocked_for_student?(student)).to eq(false)
    end

    it "returns true if the badge has no unlock conditions" do
      badge = create(:badge)
      student = create(:user)
      expect(badge.is_unlocked_for_student?(student)).to eq(true)
    end
  end

  describe "#unlock_condition_count_to_meet" do
    it "counts the number of unlock conditions required to meet to complete" do
      unearned_badge = create(:badge)
      unlock_condition = create(:unlock_condition, unlockable_id: unearned_badge.id, unlockable_type: "Badge")
      unlock_condition_2 = create(:unlock_condition, unlockable_id: unearned_badge.id, unlockable_type: "Badge")
      unlock_condition = create(:unlock_condition, unlockable_id: unearned_badge.id, unlockable_type: "Badge")
      unlock_condition_2 = create(:unlock_condition, unlockable_id: unearned_badge.id, unlockable_type: "Badge")
      expect(unearned_badge.unlock_condition_count_to_meet).to eq(4)
    end
  end

  describe "#unlock_condition_count_met_for" do
    it "tallies the number of unlock conditions a student has successfully completed" do
      unearned_badge = create(:badge)
      student = create(:user)
      assignment = create(:assignment)
      submission = create(:submission, assignment: assignment, student: student)
      badge = create(:badge)
      earned_badge = create(:earned_badge, badge: badge, student: student)
      unlock_condition = create(:unlock_condition, condition_id: badge.id, condition_type: "Badge", condition_state: "Earned", unlockable_id: unearned_badge.id, unlockable_type: "Badge")
      unlock_condition_2 = create(:unlock_condition, condition_id: assignment.id, condition_type: "Assignment", condition_state: "Submitted", unlockable_id: unearned_badge.id, unlockable_type: "Badge")
      expect(unearned_badge.unlock_condition_count_met_for(student)).to eq(2)
    end
  end

  describe "#unlock!" do
    it "updates the unlock status to true if conditions are met" do
      locked_badge = create(:badge)
      student = create(:user)
      assignment = create(:assignment)
      submission = create(:submission, assignment: assignment, student: student)
      unlock_condition = create(:unlock_condition, condition_id: assignment.id, condition_type: "Assignment", condition_state: "Submitted", unlockable_id: locked_badge.id, unlockable_type: "Badge")
      locked_badge.unlock!(student)
      unlock_state = locked_badge.unlock_states.where(student: student).first
      expect(unlock_state.unlocked).to eq(true)
    end

    it "does not update the unlock status to true if conditions are not met" do
      locked_badge = create(:badge)
      student = create(:user)
      assignment = create(:assignment)
      assignment_2 = create(:assignment)
      submission = create(:submission, assignment: assignment, student: student)
      unlock_condition = create(:unlock_condition, condition_id: assignment.id, condition_type: "Assignment", condition_state: "Submitted", unlockable_id: locked_badge.id, unlockable_type: "Badge")
      unlock_condition_2 = create(:unlock_condition, condition_id: assignment_2.id, condition_type: "Assignment", condition_state: "Submitted", unlockable_id: locked_badge.id, unlockable_type: "Badge")
      locked_badge.unlock!(student)
      unlock_state = locked_badge.unlock_states.where(student: student).first
      expect(unlock_state.unlocked).to eq(false)
    end
  end

  describe "#visible_for_student?(student)" do
    it "returns true if the badge is visible" do
      badge = create(:badge)
      student = create(:user)
      expect(badge.visible_for_student?(student)).to eq(true)
    end

    it "returns false if the badge is invisible" do
      badge = create(:badge, visible: false)
      student = create(:user)
      expect(badge.visible_for_student?(student)).to eq(false)
    end

    it "returns true if the badge is invisible but has been earned by the student" do
      badge = create(:badge)
      student = create(:user)
      earned_badge = create(:earned_badge, student: student, badge: badge)
      expect(badge.visible_for_student?(student)).to eq(true)
    end

    it "returns true if the badge is locked but visible" do
      badge = create(:badge, visible_when_locked: true)
      student = create(:user)
      unlock_condition = create(:unlock_condition, unlockable: badge)
      expect(badge.visible_for_student?(student)).to eq(true)
    end

    it "returns false if the badge is invisible when locked" do
      badge = create(:badge, visible_when_locked: false)
      student = create(:user)
      unlock_condition = create(:unlock_condition, unlockable: badge)
      expect(badge.visible_for_student?(student)).to eq(false)
    end

    it "returns true if the badge is invisible when locked and the student has met the conditions" do
      badge = create(:badge, visible_when_locked: false)
      student = create(:user)
      assignment = create(:assignment)
      submission = create(:submission, assignment: assignment, student: student)
      unlock_condition = create(:unlock_condition, unlockable: badge, condition_id: assignment.id, condition_type: "Assignment", condition_state: "Submitted")
      expect(badge.visible_for_student?(student)).to eq(false)
    end
  end

  describe "#find_or_create_unlock_state" do
    it "creates an unlock state for a student" do
      student = create(:user)
      badge = create(:badge, full_points: 1000)
      expect { badge.find_or_create_unlock_state(student.id) }.to \
        change(UnlockState,:count).by 1
    end

    it "finds an existing unlock state for a student" do
      student = create(:user)
      badge = create(:badge, full_points: 1000)
      unlock_state = create(:unlock_state, student: student, unlockable: badge)
      expect(badge.find_or_create_unlock_state(student.id)).to \
        eq(unlock_state)
    end
  end

  describe "#earned_badge_count_for_student(student)" do
    it "sums up the number of times a student has earned a specific badge" do
      student = create(:user)
      badge = create(:badge, full_points: 1000)
      second_badge = create(:badge, full_points: 200)
      earned_badge = create(:earned_badge, badge: badge, student: student)
      second_earned_badge = create(:earned_badge, badge: badge, student: student)
      third_earned_badge = create(:earned_badge, badge: second_badge, student: student)
      expect(badge.earned_badge_count_for_student(student)).to eq(2)
    end
  end

  describe "#earned_badge_total_points_for_student(student)" do
    it "sums up the total points earned for a specific badge" do
      student = create(:user)
      badge = create(:badge, full_points: 1000)
      second_badge = create(:badge, full_points: 200)
      earned_badge = create(:earned_badge, badge: badge, student: student)
      second_earned_badge = create(:earned_badge, badge: second_badge, student: student)
      expect(badge.earned_badge_total_points_for_student(student)).to eq(1000)
    end
  end

  describe "#earned_badges_this_week_count" do
    it "returns the count of submissions for this assignment type this week" do
      earlier_earned_badge = create(:earned_badge, badge: subject, updated_at: 8.days.ago)
      earned_badge = create(:earned_badge, badge: subject)
      earned_badge_2 = create(:earned_badge, badge: subject)
      expect(subject.earned_badges_this_week_count).to eq(2)
    end
  end
end
