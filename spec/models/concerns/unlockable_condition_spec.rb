describe UnlockableCondition do
  let(:course) { create(:course) }
  let(:assignment) { create(:assignment, course: course) }
  let(:badge) { create(:badge, course: course) }
  let(:student) { create(:course_membership, :student, course: course).user }

  describe "#unlock!" do
    before { assignment.save }

    it "returns a new unlock state if the goal of unlockables does not meet the number of unlocks" do
      assignment.unlock_conditions.create! condition_id: assignment.id,
        condition_type: assignment.class, condition_state: "Grade Earned", course: course
      expect(assignment.unlock!(student)).to be_an_instance_of UnlockState
      expect(assignment.unlock_states.last).to_not be_unlocked
    end

    context "when the number of conditions are met" do
      it "returns the updated unlock state when it is found" do
        condition = assignment.unlock_conditions.create condition_id: assignment.id,
          condition_type: assignment.class, condition_state: "Earned", course: course
        allow(condition).to receive(:is_complete?).with(student).and_return true
        state = assignment.unlock_states.create(student_id: student.id,
                                             unlocked: false)
        expect(assignment.unlock!(student)).to eq state
        expect(state.reload).to be_unlocked
      end

      it "returns a new unlock state if it did not exist" do
        condition = assignment.unlock_conditions.create condition_id: assignment.id,
          condition_type: assignment.class, condition_state: "Submitted", course: course
        allow(condition).to receive(:is_complete?).with(student).and_return true
        expect(assignment.unlock!(student)).to eq \
          assignment.unlock_states.last
        expect(assignment.unlock_states.last.unlockable_type).to eq assignment.class.name
        expect(assignment.unlock_states.last.student).to eq student
        expect(assignment.unlock_states.last).to be_unlocked
        expect(assignment.unlock_states.last.unlockable_id).to eq assignment.id
      end
    end

    it "updates the unlock status to true if conditions are met" do
      locked_badge = create(:badge)
      submission = create(:submission, assignment: assignment, student: student)
      unlock_condition = create(:unlock_condition, condition_id: assignment.id, condition_type: "Assignment", condition_state: "Submitted", unlockable_id: locked_badge.id, unlockable_type: "Badge")
      locked_badge.unlock!(student)
      unlock_state = locked_badge.unlock_states.where(student: student).first
      expect(unlock_state.unlocked).to eq(true)
    end

    it "does not update the unlock status to true if conditions are not met" do
      locked_badge = create(:badge)
      assignment_2 = create(:assignment)
      submission = create(:submission, assignment: assignment, student: student)
      unlock_condition = create(:unlock_condition, condition_id: assignment.id, condition_type: "Assignment", condition_state: "Submitted", unlockable_id: locked_badge.id, unlockable_type: "Badge")
      unlock_condition_2 = create(:unlock_condition, condition_id: assignment_2.id, condition_type: "Assignment", condition_state: "Submitted", unlockable_id: locked_badge.id, unlockable_type: "Badge")
      unlock_state = locked_badge.unlock!(student)
      expect(unlock_state.unlocked).to be_falsey
    end
  end

  describe "#unlock_condition_count_met_for" do
    before { assignment.save }

    it "returns zero if there are no unlock conditions" do
      expect(assignment.unlock_condition_count_met_for(student)).to be_zero
    end

    it "returns zero if none of the conditions were met for the student" do
      condition = assignment.unlock_conditions.create condition_id: assignment.id,
          condition_type: assignment.class, condition_state: "Grade Earned"
      expect(assignment.unlock_condition_count_met_for(student)).to be_zero
    end

    it "returns the number of conditions that were complete for the student" do
      met_condition = assignment.unlock_conditions.create condition_id: assignment.id,
          condition_type: assignment.class, condition_state: "Submitted"
      allow(met_condition).to receive(:is_complete?).with(student).and_return true
      condition = assignment.unlock_conditions.create condition_id: assignment.id,
          condition_type: assignment.class, condition_state: "Grade Earned"
      expect(assignment.unlock_condition_count_met_for(student)).to eq 1
    end

    it "tallies the number of unlock conditions a student has successfully completed" do
      unearned_badge = create(:badge)
      submission = create(:submission, assignment: assignment, student: student)
      earned_badge = create(:earned_badge, badge: badge, student: student)
      unlock_condition = create(:unlock_condition, condition_id: badge.id, condition_type: "Badge", condition_state: "Earned", unlockable_id: unearned_badge.id, unlockable_type: "Badge")
      unlock_condition_2 = create(:unlock_condition, condition_id: assignment.id, condition_type: "Assignment", condition_state: "Submitted", unlockable_id: unearned_badge.id, unlockable_type: "Badge")
      expect(unearned_badge.unlock_condition_count_met_for(student)).to eq(2)
    end
  end

  describe "#visible_for_student?(student)" do
    it "returns true if the assignment is visible" do
      assignment = create(:assignment)
      student = create(:user)
      expect(assignment.visible_for_student?(student)).to eq(true)
    end

    it "returns false if the assignment is invisible" do
      assignment = create(:assignment, visible: false)
      student = create(:user)
      expect(assignment.visible_for_student?(student)).to eq(false)
    end

    it "returns true if the assignment is invisible but the student has earned a grade" do
      assignment = create(:assignment)
      student = create(:user)
      grade = create(:grade, student: student, assignment: assignment)
      expect(assignment.visible_for_student?(student)).to eq(true)
    end

    it "returns true if the assignment is locked but visible" do
      assignment= create(:assignment, visible_when_locked: true)
      student = create(:user)
      unlock_condition = create(:unlock_condition, unlockable_id: assignment)
      expect(assignment.visible_for_student?(student)).to eq(true)
    end

    it "returns false if the assignment is invisible when locked and the student has not met the conditions" do
      assignment = create(:assignment, visible_when_locked: false)
      student = create(:user)
      badge = create(:badge)
      unlock_condition = create(:unlock_condition, unlockable_id: assignment.id, unlockable_type: "Assignment", condition_id: badge.id, condition_state: "Earned")
      expect(assignment.visible_for_student?(student)).to eq(false)
    end

    it "returns true if the assignment is invisible when locked and the student has met the conditions" do
      assignment = create(:assignment, visible_when_locked: false)
      student = create(:user)
      assignment_2 = create(:assignment)
      submission = create(:submission, assignment: assignment_2, student: student)
      unlock_condition = create(:unlock_condition, unlockable_id: assignment, condition_id: assignment_2.id, condition_type: "Assignment", condition_state: "Submitted")
      expect(assignment.visible_for_student?(student)).to eq(true)
    end

    it "returns true if the badge is visible" do
      expect(badge.visible_for_student?(student)).to eq(true)
    end

    it "returns false if the badge is invisible" do
      badge.visible = false
      expect(badge.visible_for_student?(student)).to eq(false)
    end

    it "returns true if the badge is invisible but has been earned by the student" do
      earned_badge = create(:earned_badge, student: student, badge: badge)
      expect(badge.visible_for_student?(student)).to eq(true)
    end

    it "returns true if the badge is locked but visible" do
      badge.visible_when_locked = true
      unlock_condition = create(:unlock_condition, unlockable: badge)
      expect(badge.visible_for_student?(student)).to eq(true)
    end

    it "returns false if the badge is invisible when locked" do
      badge.visible_when_locked = false
      unlock_condition = create(:unlock_condition, unlockable: badge, condition_id: assignment.id, condition_type: "Assignment", condition_state: "Grade Earned")
      expect(badge.visible_for_student?(student)).to eq(false)
    end

    it "returns true if the badge is invisible when locked and the student has met the conditions" do
      badge.visible_when_locked = true
      submission = create(:submission, assignment: assignment, student: student)
      unlock_condition = create(:unlock_condition, unlockable: assignment, condition_id: assignment.id, condition_type: "Assignment", condition_state: "Submitted")
      expect(badge.visible_for_student?(student)).to eq(true)
    end
  end

  describe "#is_unlocked_for_student?" do
    it "is unlocked when there are no unlock conditions present" do
      expect(assignment.is_unlocked_for_student?(student)).to eq true
    end

    it "is not unlocked when the unlock state for the student is not present" do
      assignment.unlock_conditions.build
      expect(assignment.is_unlocked_for_student?(student)).to eq false
    end

    it "is unlocked when the unlock state for the student is unlocked" do
      assignment.unlock_states.build(student_id: student.id, unlocked: true)
      expect(assignment.is_unlocked_for_student?(student)).to eq true
    end

    it "returns true if a student has met the necessary requirements to unlock the badge" do
      locked_badge = create(:badge)
      unlock_condition = create(:unlock_condition, unlockable_id: locked_badge.id, unlockable_type: "Badge", condition_id: assignment.id, condition_type: "Assignment", condition_state: "Submitted")
      unlock_condition_2 = create(:unlock_condition, unlockable_id: locked_badge.id, unlockable_type: "Badge", condition_id: badge.id, condition_type: "Badge", condition_state: "Earned", condition_value: 2)
      submission = create(:submission, student: student, assignment: assignment)
      earned_badge = create(:earned_badge, badge: badge, student: student)
      earned_badge_2 = create(:earned_badge, badge: badge, student: student)
      expect(locked_badge.is_unlocked_for_student?(student)).to eq(true)
    end

    it "returns false if a student has not met the necessary requirements to unlock the badge" do
      locked_badge = create(:badge)
      unlock_condition = create(:unlock_condition, unlockable_id: locked_badge.id, unlockable_type: "Badge", condition_id: assignment.id, condition_type: "Assignment", condition_state: "Submitted")
      unlock_condition_2 = create(:unlock_condition, unlockable_id: locked_badge.id, unlockable_type: "Badge", condition_id: assignment.id, condition_type: "Badge", condition_state: "Earned", condition_value: 2)
      submission = create(:submission, student: student, assignment: assignment)
      earned_badge = create(:earned_badge, badge: badge, student: student)
      expect(locked_badge.is_unlocked_for_student?(student)).to eq(false)
    end
  end

  describe "#description_visible_for_student?(student)" do
    it "returns true if the assignment is visible" do
      assignment = create(:assignment)
      student = create(:user)
      expect(assignment.description_visible_for_student?(student)).to eq(true)
    end

    it "returns false if the assignment is invisible" do
      assignment = create(:assignment, visible: false)
      student = create(:user)
      expect(assignment.description_visible_for_student?(student)).to eq(false)
    end

    it "returns true if the assignment description is invisible but the student has earned a grade" do
      assignment = create(:assignment, show_description_when_locked: false )
      student = create(:user)
      grade = create(:grade, student: student, assignment: assignment)
      expect(assignment.description_visible_for_student?(student)).to eq(true)
    end

    it "returns true if the assignment is locked but the description is visible" do
      assignment= create(:assignment, visible_when_locked: true,  show_description_when_locked: true )
      student = create(:user)
      unlock_condition = create(:unlock_condition, unlockable_id: assignment)
      expect(assignment.description_visible_for_student?(student)).to eq(true)
    end

    it "returns false if the assignment description is invisible when locked and the student has not met the conditions" do
      assignment = create(:assignment, visible_when_locked: true, show_description_when_locked: false )
      student = create(:user)
      badge = create(:badge)
      unlock_condition = create(:unlock_condition, unlockable_id: assignment.id, unlockable_type: "Assignment", condition_id: badge.id, condition_state: "Earned")
      expect(assignment.description_visible_for_student?(student)).to eq(false)
    end

    it "returns true if the assignment description is invisible when locked and the student has met the conditions" do
      assignment = create(:assignment, visible_when_locked: true, show_description_when_locked: false )
      student = create(:user)
      assignment_2 = create(:assignment)
      submission = create(:submission, assignment: assignment_2, student: student)
      unlock_condition = create(:unlock_condition, unlockable_id: assignment, condition_id: assignment_2.id, condition_type: "Assignment", condition_state: "Submitted")
      expect(assignment.description_visible_for_student?(student)).to eq(true)
    end
  end

  describe "#points_visible_for_student?(student)" do
    it "returns true if the assignment is visible" do
      assignment = create(:assignment)
      student = create(:user)
      expect(assignment.points_visible_for_student?(student)).to eq(true)
    end

    it "returns false if the assignment is invisible" do
      assignment = create(:assignment, visible: false)
      student = create(:user)
      expect(assignment.points_visible_for_student?(student)).to eq(false)
    end

    it "returns true if the assignment points is invisible but the student has earned a grade" do
      assignment = create(:assignment, show_points_when_locked: false )
      student = create(:user)
      grade = create(:grade, student: student, assignment: assignment)
      expect(assignment.points_visible_for_student?(student)).to eq(true)
    end

    it "returns true if the assignment is locked but the points are visible" do
      assignment= create(:assignment, visible_when_locked: true,  show_points_when_locked: true )
      student = create(:user)
      unlock_condition = create(:unlock_condition, unlockable_id: assignment)
      expect(assignment.points_visible_for_student?(student)).to eq(true)
    end

    it "returns false if the assignment points are invisible when locked and the student has not met the conditions" do
      assignment = create(:assignment, visible_when_locked: true, show_points_when_locked: false )
      student = create(:user)
      badge = create(:badge)
      unlock_condition = create(:unlock_condition, unlockable_id: assignment.id, unlockable_type: "Assignment", condition_id: badge.id, condition_state: "Earned")
      expect(assignment.points_visible_for_student?(student)).to eq(false)
    end

    it "returns true if the assignment points are invisible when locked and the student has met the conditions" do
      assignment = create(:assignment, visible_when_locked: true, show_points_when_locked: false )
      student = create(:user)
      assignment_2 = create(:assignment)
      submission = create(:submission, assignment: assignment_2, student: student)
      unlock_condition = create(:unlock_condition, unlockable_id: assignment, condition_id: assignment_2.id, condition_type: "Assignment", condition_state: "Submitted")
      expect(assignment.points_visible_for_student?(student)).to eq(true)
    end
  end

  describe "#name_visible_for_student?(student)" do
    it "returns true if the assignment is visible" do
      assignment = create(:assignment)
      student = create(:user)
      expect(assignment.name_visible_for_student?(student)).to eq(true)
    end

    it "returns false if the assignment is invisible" do
      assignment = create(:assignment, visible: false)
      student = create(:user)
      expect(assignment.name_visible_for_student?(student)).to eq(false)
    end

    it "returns true if the assignment name is invisible but the student has earned a grade" do
      assignment = create(:assignment, show_points_when_locked: false )
      student = create(:user)
      grade = create(:grade, student: student, assignment: assignment)
      expect(assignment.name_visible_for_student?(student)).to eq(true)
    end

    it "returns true if the assignment is locked but the name is visible" do
      assignment= create(:assignment, visible_when_locked: true,  show_name_when_locked: true )
      student = create(:user)
      unlock_condition = create(:unlock_condition, unlockable_id: assignment)
      expect(assignment.name_visible_for_student?(student)).to eq(true)
    end

    it "returns false if the assignment name is invisible when locked and the student has not met the conditions" do
      assignment = create(:assignment, visible_when_locked: true, show_name_when_locked: false )
      student = create(:user)
      badge = create(:badge)
      unlock_condition = create(:unlock_condition, unlockable_id: assignment.id, unlockable_type: "Assignment", condition_id: badge.id, condition_state: "Earned")
      expect(assignment.name_visible_for_student?(student)).to eq(false)
    end

    it "returns true if the assignment name is invisible when locked and the student has met the conditions" do
      assignment = create(:assignment, visible_when_locked: true, show_name_when_locked: false )
      student = create(:user)
      assignment_2 = create(:assignment)
      submission = create(:submission, assignment: assignment_2, student: student)
      unlock_condition = create(:unlock_condition, unlockable_id: assignment, condition_id: assignment_2.id, condition_type: "Assignment", condition_state: "Submitted")
      expect(assignment.name_visible_for_student?(student)).to eq(true)
    end
  end

  describe "#is_a_condition?" do
    it "returns true if the badge is an unlock condition" do
      unlock_condition = create(:unlock_condition, condition_id: badge.id, condition_type: "Badge", condition_state: "Earned")
      expect(badge.is_a_condition?).to eq(true)
    end

    it "returns false if the badge is an unlockable" do
      second_badge = create(:badge)
      unlock_condition = create(:unlock_condition, condition_id: second_badge.id, condition_type: "Badge", condition_state: "Earned", unlockable_id: badge.id, unlockable_type: "Badge")
      expect(badge.is_a_condition?).to eq(false)
    end
  end

  describe "#is_unlockable?" do
    it "returns true if the badge is an unlockable" do
      second_badge = create(:badge)
      unlock_condition = create(:unlock_condition, condition_id: second_badge.id, condition_type: "Badge", condition_state: "Earned", unlockable_id: badge.id, unlockable_type: "Badge")
      expect(badge.is_unlockable?).to eq(true)
    end

    it "returns false if the badge is a condition" do
      second_badge = create(:badge)
      unlock_condition = create(:unlock_condition, condition_id: badge.id, condition_type: "Badge", condition_state: "Earned", unlockable_id: second_badge.id, unlockable_type: "Badge")
      expect(badge.is_unlockable?).to eq(false)
    end
  end

  describe "#unlockable" do
    it "returns the unlockable object from a condition" do
      second_badge = create(:badge)
      unlock_condition = create(:unlock_condition, condition_id: second_badge.id, condition_type: "Badge", condition_state: "Earned", unlockable_id: badge.id, unlockable_type: "Badge")
      expect(second_badge.unlockable.id).to eq(badge.id)
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

  describe "#find_or_create_unlock_state" do
    it "creates an unlock state for a student" do
      expect { assignment.find_or_create_unlock_state(student.id) }.to \
        change(UnlockState,:count).by 1
    end

    it "finds an existing unlock state for a student" do
      unlock_state = create(:unlock_state, student: student, unlockable: assignment, unlockable_type: "Assignment")
      expect(assignment.find_or_create_unlock_state(student.id)).to \
        eq(unlock_state)
    end
  end
end
