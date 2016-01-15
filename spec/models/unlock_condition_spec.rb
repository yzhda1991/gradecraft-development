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
      unlock_condition = UnlockCondition.new condition_id: badge.id, condition_type: "Badge", condition_state: "Earned", condition_value: 2, unlockable_id: unlockable_assignment.id, unlockable_type: "Assignment"
      expect(unlock_condition.is_complete?(student)).to eq(true)
    end

    it "returns false if the badge has been earned enough times" do
      student = create(:user)
      student_earned_badge = create(:earned_badge, badge: badge, student: student)
      student_earned_badge_2 = create(:earned_badge, badge: badge, student: student)
      unlock_condition = UnlockCondition.new condition_id: badge.id, condition_type: "Badge", condition_state: "Earned", condition_value: 3, unlockable_id: unlockable_assignment.id, unlockable_type: "Assignment"
      expect(unlock_condition.is_complete?(student)).to eq(false)
    end

    it "returns true if the badge has been earned enough times by a specific date" do
      student = create(:user)
      student_earned_badge = create(:earned_badge, badge: badge, student: student)
      student_earned_badge_2 = create(:earned_badge, badge: badge, student: student)
      unlock_condition = UnlockCondition.new condition_id: badge.id, condition_type: "Badge", condition_state: "Earned", condition_value: 2, condition_date: (Date.today + 1), unlockable_id: unlockable_assignment.id, unlockable_type: "Assignment"
      expect(unlock_condition.is_complete?(student)).to eq(true)
    end

    it "returns false if the badge has been earned by a specific date but not enough times" do
      student = create(:user)
      student_earned_badge = create(:earned_badge, badge: badge, student: student)
      student_earned_badge_2 = create(:earned_badge, badge: badge, student: student)
      unlock_condition = UnlockCondition.new condition_id: badge.id, condition_type: "Badge", condition_state: "Earned", condition_value: 3, condition_date: (Date.today + 1), unlockable_id: unlockable_assignment.id, unlockable_type: "Assignment"
      expect(unlock_condition.is_complete?(student)).to eq(false)
    end

    it "returns false if the badge has been earned enough times but not by a specific date" do
      student = create(:user)
      student_earned_badge = create(:earned_badge, badge: badge, student: student)
      student_earned_badge_2 = create(:earned_badge, badge: badge, student: student)
      unlock_condition = UnlockCondition.new condition_id: badge.id, condition_type: "Badge", condition_state: "Earned", condition_value: 3, condition_date: (Date.today - 1), unlockable_id: unlockable_assignment.id, unlockable_type: "Assignment"
      expect(unlock_condition.is_complete?(student)).to eq(false)
    end

    it "returns true if the assignment has been submitted" do
      student = create(:user)
      student_submission = create(:submission, assignment: assignment, student: student)
      unlock_condition = UnlockCondition.new condition_id: assignment.id, condition_type: "Assignment", condition_state: "Submitted"
      expect(unlock_condition.is_complete?(student)).to eq(true)
    end

    it "returns false if the assignment has not been submitted" do
      student = create(:user)
      unlock_condition = UnlockCondition.new condition_id: assignment.id, condition_type: "Assignment", condition_state: "Submitted"
      expect(unlock_condition.is_complete?(student)).to eq(false)
    end

    it "returns true if the assignment has been submitted by a specific date" do
      student = create(:user)
      student_submission = create(:submission, assignment: assignment, student: student, submitted_at: DateTime.now)
      unlock_condition = UnlockCondition.new condition_id: assignment.id, condition_type: "Assignment", condition_state: "Submitted", condition_date: (Date.today + 1)
      expect(unlock_condition.is_complete?(student)).to eq(true)
    end

    it "returns false if the assignment has been submitted but not by the specified date" do
      student = create(:user)
      student_submission = create(:submission, assignment: assignment, student: student, submitted_at: DateTime.now)
      unlock_condition = UnlockCondition.new condition_id: assignment.id, condition_type: "Assignment", condition_state: "Submitted", condition_date: (Date.today - 1)
      expect(unlock_condition.is_complete?(student)).to eq(false)
    end

    it "returns true if the grade earned is present and student visible" do
      student = create(:user)
      grade = create(:grade, assignment: assignment, student: student, raw_score: 100, status: "Released")
      unlock_condition = UnlockCondition.new condition_id: assignment.id, condition_type: "Assignment", condition_state: "Grade Earned"
      expect(unlock_condition.is_complete?(student)).to eq(true)
    end

    it "returns false if the grade earned is present but not student visible" do
      student = create(:user)
      grade = create(:grade, assignment: assignment, student: student, raw_score: 100, status: nil)
      unlock_condition = UnlockCondition.new condition_id: assignment.id, condition_type: "Assignment", condition_state: "Grade Earned"
      expect(unlock_condition.is_complete?(student)).to eq(false)
    end

    it "returns true if the grade earned meets the condition value" do
      student = create(:user)
      grade = create(:grade, assignment: assignment, student: student, raw_score: 100, status: "Released")
      unlock_condition = UnlockCondition.new condition_id: assignment.id, condition_type: "Assignment", condition_state: "Grade Earned", condition_value: 100
      expect(unlock_condition.is_complete?(student)).to eq(true)
    end

    it "returns false if the grade earned does not meet the condition value" do
      student = create(:user)
      grade = create(:grade, assignment: assignment, student: student, raw_score: 99, status: "Released")
      unlock_condition = UnlockCondition.new condition_id: assignment.id, condition_type: "Assignment", condition_state: "Grade Earned", condition_value: 100
      expect(unlock_condition.is_complete?(student)).to eq(false)
    end

    it "returns false if the grade earned meets the condition value but is not student visible" do
      student = create(:user)
      grade = create(:grade, assignment: assignment, student: student, raw_score: 100, status: nil, instructor_modified: false, graded_at: DateTime.now)
      unlock_condition = UnlockCondition.new condition_id: assignment.id, condition_type: "Assignment", condition_state: "Grade Earned", condition_value: 100
      expect(unlock_condition.is_complete?(student)).to eq(false)
    end

    it "returns true if the grade earned meets the condition date" do
      student = create(:user)
      grade = create(:grade, assignment: assignment, student: student, raw_score: 100, status: "Graded", instructor_modified: true, graded_at: DateTime.now)
      unlock_condition = UnlockCondition.new condition_id: assignment.id, condition_type: "Assignment", condition_state: "Grade Earned", condition_date: (Date.today + 1)
      expect(unlock_condition.is_complete?(student)).to eq(true)
    end

    it "returns false if the grade earned did not meet the condition date" do
      student = create(:user)
      grade = create(:grade, assignment: assignment, student: student, raw_score: 100, status: "Graded", instructor_modified: true, graded_at: DateTime.now)
      unlock_condition = UnlockCondition.new condition_id: assignment.id, condition_type: "Assignment", condition_state: "Grade Earned", condition_date: (Date.today - 1)
      expect(unlock_condition.is_complete?(student)).to eq(false)
    end

    it "returns true if the grade earned meets condition value and the condition date" do
      student = create(:user)
      grade = create(:grade, assignment: assignment, student: student, raw_score: 100, status: "Graded", instructor_modified: true, graded_at: DateTime.now)
      unlock_condition = UnlockCondition.new condition_id: assignment.id, condition_type: "Assignment", condition_state: "Grade Earned", condition_value: 100, condition_date: (Date.today + 1)
      expect(unlock_condition.is_complete?(student)).to eq(true)
    end

    it "returns false if the grade earned does not meet the condition value but does meet the condition date" do
      student = create(:user)
      grade = create(:grade, assignment: assignment, student: student, raw_score: 90, status: "Graded", instructor_modified: true)
      unlock_condition = UnlockCondition.new condition_id: assignment.id, condition_type: "Assignment", condition_state: "Grade Earned", condition_value: 100, condition_date: (Date.today + 1)
      expect(unlock_condition.is_complete?(student)).to eq(false)
    end

    it "returns false if the grade earned does meet the condition value but does not meet the condition date" do
      student = create(:user)
      grade = create(:grade, assignment: assignment, student: student, raw_score: 100, status: "Graded", instructor_modified: true, graded_at: DateTime.now)
      unlock_condition = UnlockCondition.new condition_id: assignment.id, condition_type: "Assignment", condition_state: "Grade Earned", condition_value: 100, condition_date: (Date.today - 1)
      expect(unlock_condition.is_complete?(student)).to eq(false)
    end

    it "returns true if the grade feedback is read" do
      student = create(:user)
      grade = create(:grade, assignment: assignment, student: student, status: "Graded", instructor_modified: true, feedback_read: true)
      unlock_condition = UnlockCondition.new condition_id: assignment.id, condition_type: "Assignment", condition_state: "Feedback Read"
      expect(unlock_condition.is_complete?(student)).to eq(true)
    end

    it "returns false if the grade feedback is not read" do
      student = create(:user)
      grade = create(:grade, assignment: assignment, student: student, status: "Graded", instructor_modified: true, feedback_read: false)
      unlock_condition = UnlockCondition.new condition_id: assignment.id, condition_type: "Assignment", condition_state: "Feedback Read"
      expect(unlock_condition.is_complete?(student)).to eq(false)
    end

    it "returns true if the grade feedback is read by specified condition date" do
      student = create(:user)
      grade = create(:grade, assignment: assignment, student: student, status: "Graded", instructor_modified: true, feedback_read: true, feedback_read_at: Date.today)
      unlock_condition = UnlockCondition.new condition_id: assignment.id, condition_type: "Assignment", condition_state: "Feedback Read", condition_date: Date.today + 1
      expect(unlock_condition.is_complete?(student)).to eq(true)
    end

    it "returns false if the grade feedback is read but not by the specified condition date" do
      student = create(:user)
      grade = create(:grade, assignment: assignment, student: student, status: "Graded", instructor_modified: true, feedback_read: true, feedback_read_at: Date.today)
      unlock_condition = UnlockCondition.new condition_id: assignment.id, condition_type: "Assignment", condition_state: "Feedback Read", condition_date: Date.today - 1
      expect(unlock_condition.is_complete?(student)).to eq(false)
    end
  end

  describe "#is_complete_for_group(group)" do

    it "returns false if the students in the group have not earned the badge" do
      course = create(:course)
      student = create(:user)
      student_2 = create(:user)
      student_3 = create(:user)
      group = create(:group, course: course)
      group_assignment = create(:assignment, grade_scope: "Group", course: course)
      group_membership = create(:group_membership, group: group, student: student)
      group_membership_2 = create(:group_membership, group: group, student: student_2)
      group_membership_3 = create(:group_membership, group: group, student: student_3)
      assignment_group = create(:assignment_group, group: group, assignment: group_assignment)
      new_badge = create(:badge, course: course)
      unlock_condition = UnlockCondition.new unlockable_id: group_assignment.id, unlockable_type: "Assignment", condition_id: new_badge.id, condition_type: "Badge", condition_state: "Earned"
      expect(unlock_condition.is_complete_for_group?(group)).to eq(false)
    end

    it "returns false if one of the students in the group has not earned the badge" do
      course = create(:course)
      student = create(:user)
      student_2 = create(:user)
      student_3 = create(:user)
      group = create(:group, course: course)
      group_assignment = create(:assignment, grade_scope: "Group", course: course)
      group_membership = create(:group_membership, group: group, student: student)
      group_membership_2 = create(:group_membership, group: group, student: student_2)
      group_membership_3 = create(:group_membership, group: group, student: student_3)
      assignment_group = create(:assignment_group, group: group, assignment: group_assignment)
      new_badge = create(:badge, course: course)
      unlock_condition = UnlockCondition.new unlockable_id: group_assignment.id, unlockable_type: "Assignment", condition_id: new_badge.id, condition_type: "Badge", condition_state: "Earned"
      earned_badge = create(:earned_badge, badge: new_badge, student: student, student_visible: true)
      expect(unlock_condition.is_complete_for_group?(group)).to eq(false)
    end

    it "returns true if all of the students in the group have earned the badge" do
      skip "pending"
      course = create(:course)
      student = create(:user)
      student_2 = create(:user)
      student_3 = create(:user)
      student.courses << course
      student_2.courses << course
      student_3.courses << course
      group = build(:group, course: course)
      group_membership = create(:group_membership, group: group, student: student)
      group_membership_2 = create(:group_membership, group: group, student: student_2)
      group_membership_3 = create(:group_membership, group: group, student: student_3)
      group_assignment = create(:assignment, grade_scope: "Group")
      assignment_group = create(:assignment_group, group: group, assignment: group_assignment)
      new_badge = create(:badge, course: course)
      unlock_condition = UnlockCondition.create unlockable_id: group_assignment.id, unlockable_type: "Assignment", condition_id: new_badge.id, condition_type: "Badge", condition_state: "Earned"
      earned_badge = create(:earned_badge, badge: new_badge, student: student, student_visible: true)
      earned_badge_2 = create(:earned_badge, badge: new_badge, student: student_2, student_visible: true)
      earned_badge_3 = create(:earned_badge, badge: new_badge, student: student_3, student_visible: true)
      expect(group.group_memberships.count).to eq 3
      #expect(unlock_condition.is_complete_for_group?(@group)).to eq(true)
    end

  end

  describe "#requirements_description_sentence" do
    it "returns a sentence summarizing a badge unlock condition" do
      expect(subject.requirements_description_sentence).to eq("Earn the #{badge.name} Badge")
    end

    it "returns a sentence summarizing an assignment feedback read unlock condition" do
      unlock_condition = UnlockCondition.new condition_id: assignment.id, condition_type: "Assignment", condition_state: "Feedback Read"
      expect(unlock_condition.requirements_description_sentence).to eq("Read the feedback for the #{assignment.name} Assignment")
    end

    it "returns a sentence summarizing an assignment submission unlock condition" do
      unlock_condition = UnlockCondition.new condition_id: assignment.id, condition_type: "Assignment", condition_state: "Submitted"
      expect(unlock_condition.requirements_description_sentence).to eq("Submit the #{assignment.name} Assignment")
    end

    it "returns a sentence summarizing an grade earned unlock condition" do
      unlock_condition = UnlockCondition.new condition_id: assignment.id, condition_type: "Assignment", condition_state: "Grade Earned"
      expect(unlock_condition.requirements_description_sentence).to eq("Earn a grade for the #{assignment.name} Assignment")
    end
  end

  describe "#key_description_sentence" do
    it "returns a sentence summarizing the badge as an unlock key" do
      expect(subject.key_description_sentence).to eq("Earning it unlocks the #{unlockable_assignment.name} Assignment")
    end

    it "returns a sentence summarizing an assignment feedback read unlock condition" do
      subject.condition_state = "Feedback Read"
      expect(subject.key_description_sentence).to eq("Reading the feedback for it unlocks the #{unlockable_assignment.name} Assignment")
    end

    it "returns a sentence summarizing an assignment submission unlock condition" do
      subject.condition_state = "Submitted"
      expect(subject.key_description_sentence).to eq("Submitting it unlocks the #{unlockable_assignment.name} Assignment")
    end

    it "returns a sentence summarizing an grade earned unlock condition" do
      subject.condition_state = "Grade Earned"
      expect(subject.key_description_sentence).to eq("Earning a grade for it unlocks the #{unlockable_assignment.name} Assignment")
    end
  end
end
