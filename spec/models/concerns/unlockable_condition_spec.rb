describe UnlockableCondition do
  subject { build(:assignment) }

  describe "#unlock!" do
    let(:student) { create :user }
    before { subject.save }

    it "returns a new unlock state if the goal of unlockables does not meet the number of unlocks" do
      subject.unlock_conditions.create! condition_id: subject.id,
        condition_type: subject.class, condition_state: "Grade Earned"
      expect(subject.unlock!(student)).to be_an_instance_of UnlockState
      expect(subject.unlock_states.last).to_not be_unlocked
    end

    context "when the number of conditions are met" do
      it "returns the updated unlock state when it is found" do
        condition = subject.unlock_conditions.create condition_id: subject.id,
          condition_type: subject.class, condition_state: "Earned"
        allow(condition).to receive(:is_complete?).with(student).and_return true
        state = subject.unlock_states.create(student_id: student.id,
                                             unlocked: false)
        expect(subject.unlock!(student)).to eq state
        expect(state.reload).to be_unlocked
      end

      it "returns a new unlock state if it did not exist" do
        condition = subject.unlock_conditions.create condition_id: subject.id,
          condition_type: subject.class, condition_state: "Submitted"
        allow(condition).to receive(:is_complete?).with(student).and_return true
        expect(subject.unlock!(student)).to eq \
          subject.unlock_states.last
        expect(subject.unlock_states.last.unlockable_type).to eq subject.class.name
        expect(subject.unlock_states.last.student).to eq student
        expect(subject.unlock_states.last).to be_unlocked
        expect(subject.unlock_states.last.unlockable_id).to eq subject.id
      end
    end
  end

  describe "#unlock_condition_count_met_for" do
    let(:student) { create :user }
    before { subject.save }

    it "returns zero if there are no unlock conditions" do
      expect(subject.unlock_condition_count_met_for(student)).to be_zero
    end

    it "returns zero if none of the conditions were met for the student" do
      condition = subject.unlock_conditions.create condition_id: subject.id,
          condition_type: subject.class, condition_state: "Grade Earned"
      expect(subject.unlock_condition_count_met_for(student)).to be_zero
    end

    it "returns the number of conditions that were complete for the student" do
      met_condition = subject.unlock_conditions.create condition_id: subject.id,
          condition_type: subject.class, condition_state: "Submitted"
      allow(met_condition).to receive(:is_complete?).with(student).and_return true
      condition = subject.unlock_conditions.create condition_id: subject.id,
          condition_type: subject.class, condition_state: "Grade Earned"
      expect(subject.unlock_condition_count_met_for(student)).to eq 1
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
  end

  describe "#is_unlocked_for_student?" do
    let(:student) { create :user }

    it "is unlocked when there are no unlock conditions present" do
      expect(subject.is_unlocked_for_student?(student)).to eq true
    end

    it "is not unlocked when the unlock state for the student is not present" do
      subject.unlock_conditions.build
      expect(subject.is_unlocked_for_student?(student)).to eq false
    end

    it "is unlocked when the unlock state for the student is unlocked" do
      subject.unlock_states.build(student_id: student.id, unlocked: true)
      expect(subject.is_unlocked_for_student?(student)).to eq true
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
end
