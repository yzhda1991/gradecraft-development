describe UnlockCondition do
  let(:course) { create :course }
  let(:badge) { create :badge, name: "fancy name", course: course }
  let(:unlockable_badge) { create :badge, name: "unlockable badge", course: course }
  let(:assignment) { create :assignment, name: "fancier name", course: course }
  let(:assignment_type) { create :assignment_type, name: "zootopian name", course: course }
  let :unlockable_assignment do
    create :assignment, name: "unlockable assignment", course: course
  end
  let(:student) { create(:user) }
  let(:student_2) { create(:user) }
  let(:student_3) { create(:user) }
  let(:student_4) { create(:user) }
  let(:group) { create(:group, course: course) }

  subject do
    UnlockCondition.new(
      condition_id: badge.id,
      condition_type: "Badge",
      condition_state: "Earned",
      unlockable_id: unlockable_assignment.id,
      unlockable_type: "Assignment"
    )
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
      assignment_condition_unlock = UnlockCondition.new(
        condition_id: assignment.id,
        condition_type: "Assignment",
        condition_state: "Submitted"
      )
      expect(assignment_condition_unlock.name).to eq "fancier name"
    end
  end

  describe "#unlockable_name" do
    it "returns the name of a badge to be unlocked" do
      unlockable_badge_subject = UnlockCondition.new(
        condition_id: badge.id,
        condition_type: "Badge",
        condition_state: "Earned",
        unlockable_id: unlockable_badge.id,
        unlockable_type: "Badge"
      )
      expect(unlockable_badge_subject.unlockable_name).to eq "unlockable badge"
    end

    it "returns the name of an assignment to be unlocked" do
      unlockable_assignment_subject = UnlockCondition.new(
        condition_id: assignment.id,
        condition_type: "Assignment",
        condition_state: "Submitted",
        unlockable_id: unlockable_assignment.id,
        unlockable_type: "Assignment"
      )
      expect(unlockable_assignment_subject .unlockable_name).to \
        eq "unlockable assignment"
    end
  end

  describe "#is_complete? badge conditions" do
    describe "with a condition state of 'Earned'" do
      it "returns true if the badge has been earned once" do
        student = create(:user)
        create(:earned_badge, badge: badge, student: student)
        expect(subject.is_complete?(student)).to eq(true)
      end

      it "returns false if the badge has not been earned" do
        student = create(:user)
        expect(subject.is_complete?(student)).to eq(false)
      end

      it "returns true if the badge has been earned enough times" do
        student = create(:user)
        create(:earned_badge, badge: badge, student: student)
        create(:earned_badge, badge: badge, student: student)
        unlock_condition = UnlockCondition.new(
          condition_id: badge.id, condition_type: "Badge",
          condition_state: "Earned", condition_value: 2,
          unlockable_id: unlockable_assignment.id,
          unlockable_type: "Assignment"
        )
        expect(unlock_condition.is_complete?(student)).to eq(true)
      end

      it "returns false if the badge has been earned enough times" do
        student = create(:user)
        create(:earned_badge, badge: badge, student: student)
        create(:earned_badge, badge: badge, student: student)
        unlock_condition = UnlockCondition.new(
          condition_id: badge.id, condition_type: "Badge",
          condition_state: "Earned", condition_value: 3,
          unlockable_id: unlockable_assignment.id, unlockable_type: "Assignment"
        )
        expect(unlock_condition.is_complete?(student)).to eq(false)
      end

      it "returns true if the badge has been earned enough times and on time" do
        student = create(:user)
        create(:earned_badge, badge: badge, student: student)
        create(:earned_badge, badge: badge, student: student)
        unlock_condition = UnlockCondition.new(
          condition_id: badge.id, condition_type: "Badge",
          condition_state: "Earned", condition_value: 2,
          condition_date: (Date.today + 1),
          unlockable_id: unlockable_assignment.id, unlockable_type: "Assignment"
        )
        expect(unlock_condition.is_complete?(student)).to eq(true)
      end

      it "returns false if the badge has been earned on time but not enough" do
        student = create(:user)
        create(:earned_badge, badge: badge, student: student)
        create(:earned_badge, badge: badge, student: student)
        unlock_condition = UnlockCondition.new(
          condition_id: badge.id, condition_type: "Badge",
          condition_state: "Earned", condition_value: 3,
          condition_date: (Date.today + 1),
          unlockable_id: unlockable_assignment.id,
          unlockable_type: "Assignment"
        )
        expect(unlock_condition.is_complete?(student)).to eq(false)
      end

      it "returns false for badge earned enough but not on time" do
        student = create(:user)
        create(:earned_badge, badge: badge, student: student)
        create(:earned_badge, badge: badge, student: student)
        unlock_condition = UnlockCondition.new(
          condition_id: badge.id,
          condition_type: "Badge",
          condition_state: "Earned",
          condition_value: 3, condition_date: (Date.today - 1),
          unlockable_id: unlockable_assignment.id,
          unlockable_type: "Assignment"
        )
        expect(unlock_condition.is_complete?(student)).to eq(false)
      end
    end
  end

  describe "#is_complete? assignment conditions" do
    describe "with a condition state of 'Submitted'" do
      let(:student) { create :user }
      let :unlock_condition do
        UnlockCondition.new(
          condition_id: assignment.id,
          condition_type: "Assignment",
          condition_state: "Submitted"
        )
      end

      it "return false for group assignments if student is not in a group" do
        assignment.update(grade_scope: "Group")
        expect(unlock_condition.is_complete?(student)).to eq(false)
      end

      it "returns false for group assignments if they have not submitted it" do
        assignment.update(grade_scope: "Group")
        group = create(:group)
        group.students << student
        group.assignments << assignment
        expect(unlock_condition.is_complete?(student)).to eq(false)
      end

      it "returns true if the group has submitted their assignment" do
        assignment.update(grade_scope: "Group")
        group = create(:group)
        group.students << student
        group.assignments << assignment
        submission = create(:submission, assignment: assignment, group: group, student_id: nil)
        expect(unlock_condition.is_complete?(student)).to eq(true)
      end

      it "returns false if the assignment has not been submitted" do
        expect(unlock_condition.is_complete?(student)).to eq(false)
      end

      describe "with submission" do
        before do
          create(:submission, assignment: assignment,
                              student: student,
                              submitted_at: DateTime.now
                )
        end

        it "returns true if the assignment has been submitted" do
          expect(unlock_condition.is_complete?(student)).to eq(true)
        end

        it "returns false when assignment has been submitted late" do
          unlock_condition.update(condition_date: (Date.today - 1))
          expect(unlock_condition.is_complete?(student)).to eq(false)
        end

        it "returns true if the assignment has been submitted on time" do
          unlock_condition.update(condition_date: (Date.today + 1))
          expect(unlock_condition.is_complete?(student)).to eq(true)
        end
      end
    end

    describe "with a condition state of 'Grade Earned'" do
      it "returns true if the grade earned is present and student visible" do
        student = create(:user)
        create(:student_visible_grade, assignment: assignment, student: student, raw_points: 100)
        unlock_condition = UnlockCondition.new(
          condition_id: assignment.id, condition_type: "Assignment",
          condition_state: "Grade Earned"
        )
        expect(unlock_condition.is_complete?(student)).to eq(true)
      end

      it "returns false if the grade earned is not student visible" do
        student = create(:user)
        create(:grade, assignment: assignment, student: student, raw_points: 100, status: nil)
        unlock_condition = UnlockCondition.new(
          condition_id: assignment.id, condition_type: "Assignment",
          condition_state: "Grade Earned"
        )
        expect(unlock_condition.is_complete?(student)).to eq(false)
      end

      it "returns true if the grade earned meets the condition value" do
        student = create(:user)
        create(:student_visible_grade, assignment: assignment, student: student, raw_points: 100)
        unlock_condition = UnlockCondition.new(
          condition_id: assignment.id, condition_type: "Assignment",
          condition_state: "Grade Earned", condition_value: 100
        )
        expect(unlock_condition.is_complete?(student)).to eq(true)
      end

      it "returns false if the grade earned is less than the condition value" do
        student = create(:user)
        create(:student_visible_grade, assignment: assignment, student: student, raw_points: 99)
        unlock_condition = UnlockCondition.new(
          condition_id: assignment.id, condition_type: "Assignment",
          condition_state: "Grade Earned", condition_value: 100)
        expect(unlock_condition.is_complete?(student)).to eq(false)
      end

      it "returns false if the grade earned is a zero score" do
        student = create(:user)
        create(:student_visible_grade, assignment: assignment, student: student, raw_points: 0)
        unlock_condition = UnlockCondition.new(
          condition_id: assignment.id, condition_type: "Assignment",
          condition_state: "Grade Earned")
        expect(unlock_condition.is_complete?(student)).to eq(false)
      end

      it "returns false if condition is met but not student visible" do
        student = create(:user)
        create(:grade, assignment: assignment, student: student, raw_points: 100, status: nil, instructor_modified: false,
                  graded_at: DateTime.now
        )
        unlock_condition = UnlockCondition.new(
          condition_id: assignment.id, condition_type: "Assignment",
          condition_state: "Grade Earned", condition_value: 100)
        expect(unlock_condition.is_complete?(student)).to eq(false)
      end

      it "returns true if the grade earned meets the condition date" do
        student = create(:user)
        create(:student_visible_grade, assignment: assignment, student: student, raw_points: 100, instructor_modified:
                  true, graded_at: DateTime.now
        )
        unlock_condition = UnlockCondition.new(
          condition_id: assignment.id, condition_type: "Assignment",
          condition_state: "Grade Earned", condition_date: (Date.today + 1)
        )
        expect(unlock_condition.is_complete?(student)).to eq(true)
      end

      it "returns false if the grade earned did not meet the condition date" do
        student = create(:user)
        create(:student_visible_grade, assignment: assignment, student: student, raw_points: 100, instructor_modified: true,
                  graded_at: DateTime.now
        )
        unlock_condition = UnlockCondition.new(
          condition_id: assignment.id, condition_type: "Assignment",
          condition_state: "Grade Earned", condition_date: (Date.today - 1)
        )
        expect(unlock_condition.is_complete?(student)).to eq(false)
      end

      it "returns true if the grade earned meets condition value and date" do
        student = create(:user)
        create(:student_visible_grade, assignment: assignment, student: student, raw_points: 100, instructor_modified: true,
                  graded_at: DateTime.now
        )
        unlock_condition = UnlockCondition.new(
          condition_id: assignment.id, condition_type: "Assignment",
          condition_state: "Grade Earned", condition_value: 100,
          condition_date: (Date.today + 1)
        )
        expect(unlock_condition.is_complete?(student)).to eq(true)
      end

      it "returns false if grade earned meets condition date but not value" do
        student = create(:user)
        create(:student_visible_grade, assignment: assignment, student: student, raw_points: 90, instructor_modified: true
        )
        unlock_condition = UnlockCondition.new(
          condition_id: assignment.id, condition_type: "Assignment",
          condition_state: "Grade Earned", condition_value: 100,
          condition_date: (Date.today + 1)
        )
        expect(unlock_condition.is_complete?(student)).to eq(false)
      end

      it "returns false if grade earned meets condition value but not date" do
        student = create(:user)
        create(:student_visible_grade, assignment: assignment, student: student, raw_points: 100, instructor_modified: true,
                  graded_at: DateTime.now
        )
        unlock_condition = UnlockCondition.new(
          condition_id: assignment.id, condition_type: "Assignment",
          condition_state: "Grade Earned", condition_value: 100,
          condition_date: (Date.today - 1)
        )
        expect(unlock_condition.is_complete?(student)).to eq(false)
      end
    end

    describe "with a condition state of 'Feedback Read'" do
      it "returns true if the grade feedback is read" do
        student = create(:user)
        create(:student_visible_grade, assignment: assignment, student: student,
          instructor_modified: true, feedback_read: true
        )
        unlock_condition = UnlockCondition.new(
          condition_id: assignment.id, condition_type: "Assignment",
          condition_state: "Feedback Read"
        )
        expect(unlock_condition.is_complete?(student)).to eq(true)
      end

      it "returns false if the grade feedback is not read" do
        student = create(:user)
        create(:student_visible_grade, assignment: assignment, student: student,
          instructor_modified: true, feedback_read: false
        )
        unlock_condition = UnlockCondition.new(
          condition_id: assignment.id, condition_type: "Assignment",
          condition_state: "Feedback Read"
        )
        expect(unlock_condition.is_complete?(student)).to eq(false)
      end

      it "returns true if the grade feedback is read by specified date" do
        student = create(:user)
        create(:student_visible_grade, assignment: assignment, student: student,
          instructor_modified: true, feedback_read: true, feedback_read_at: Date.today
        )
        unlock_condition = UnlockCondition.new(
          condition_id: assignment.id, condition_type: "Assignment",
          condition_state: "Feedback Read", condition_date: Date.today + 1
        )
        expect(unlock_condition.is_complete?(student)).to eq(true)
      end

      it "returns false if feedback read but not by the date" do
        student = create(:user)
        create(:student_visible_grade, assignment: assignment, student: student,
          instructor_modified: true, feedback_read: true, feedback_read_at: Date.today
        )
        unlock_condition = UnlockCondition.new(
          condition_id: assignment.id, condition_type: "Assignment",
          condition_state: "Feedback Read", condition_date: Date.today - 1
        )
        expect(unlock_condition.is_complete?(student)).to eq(false)
      end
    end
  end

  describe "#is_complete? course conditions" do
    describe "with a condition state of Earned X Points minimum" do
      let(:course) { create :course }
      let(:student) { create :user }
      let :unlock_condition do
        UnlockCondition.create(
          condition_id: course.id,
          condition_type: "Course",
          condition_state: "Earned",
          condition_value: 100000
        )
      end

      it "return false if student has not earned enough points" do
        course_membership = create(:course_membership, :student, score: 0, user: student, course: course)
        expect(unlock_condition.is_complete?(student)).to eq(false)
      end

      it "return true if student has met the minimum number of points" do
        course_membership = create(:course_membership, :student, score: 100000, user: student, course: course)
        expect(unlock_condition.is_complete?(student)).to eq(true)
      end
    end
  end

  describe "#is_complete? assignment type conditions" do
    describe "with a condition state of completing X assignments" do
      let(:course) { create :course }
      let(:student) { create :user }
      let(:assignment_at) { create(:assignment, assignment_type: assignment_type) }
      let(:assignment_at2) { create(:assignment, assignment_type: assignment_type) }
      let :unlock_condition do
        UnlockCondition.create(
          condition_id: assignment_type.id,
          condition_type: "AssignmentType",
          condition_state: "Assignments Completed",
          condition_value: 2
        )
      end

      it "return false if student has not done enough assignments" do
        create(:grade, student: student, assignment: assignment_at)
        expect(unlock_condition.is_complete?(student)).to eq(false)
      end

      it "return true if student has done enough assignments" do
        g1 = create(:student_visible_grade, raw_points: 100, student: student, assignment: assignment_at)
        g2 = create(:student_visible_grade, raw_points: 100, student: student, assignment: assignment_at2)
        expect(unlock_condition.is_complete?(student)).to eq(true)
      end
    end

    describe "with a condition state of earning a minimum of X points in the type" do
      let(:course) { create :course }
      let(:student) { create :user }
      let :unlock_condition do
        UnlockCondition.create(
          condition_id: assignment_type.id,
          condition_type: "AssignmentType",
          condition_state: "Minimum Points Earned",
          condition_value: 10000
        )
      end
      let(:assignment_2) { create(:assignment, assignment_type: assignment_type) }
      let(:assignment_3) { create(:assignment, assignment_type: assignment_type) }

      it "return false if student has not earned enough points" do
        create(:grade, student: student, assignment: assignment_2, raw_points: 5000)
        expect(unlock_condition.is_complete?(student)).to eq(false)
      end

      it "return true if student has met the minimum number of points" do
        create(:student_visible_grade, student: student, assignment: assignment_2, raw_points: 5000)
        create(:student_visible_grade, student: student, assignment: assignment_3, raw_points: 5000)
        expect(unlock_condition.is_complete?(student)).to eq(true)
      end
    end
  end

  describe "with a condition state of 'Passed'" do
    it "returns true if the grade is passed and student visible" do
      student = create(:user)
      create(:student_visible_grade, assignment: assignment, student: student, pass_fail_status: "Pass")
      unlock_condition = UnlockCondition.new(
        condition_id: assignment.id, condition_type: "Assignment",
        condition_state: "Passed"
      )
      expect(unlock_condition.is_complete?(student)).to eq(true)
    end

    it "returns false if the grade is failed and student visible" do
      student = create(:user)
      create(:student_visible_grade, assignment: assignment, student: student, pass_fail_status: "Fail")
      unlock_condition = UnlockCondition.new(
        condition_id: assignment.id, condition_type: "Assignment",
        condition_state: "Passed"
      )
      expect(unlock_condition.is_complete?(student)).to eq(false)
    end
  end

  describe "#is_complete_for_group(group)" do
    let(:course) { create(:course) }
    let(:assignment) { create(:assignment, grade_scope: "Group", course: course) }
    let(:assignment_group) { create(:assignment_group, group: group, assignment: assignment) }
    let(:new_badge) { create(:badge, course: course) }
    let(:unlock_condition) { create(:unlock_condition, unlockable_id: assignment.id, unlockable_type: "Assignment", condition_id: new_badge.id, condition_type: "Badge", condition_state: "Earned") }

    it "returns false if students in the group have not earned the badge" do
      expect(unlock_condition.is_complete_for_group?(group)).to eq(false)
    end

    it "returns false if one student in the group has not earned the badge" do
      create(:earned_badge, badge: new_badge, student: student, )
      expect(unlock_condition.is_complete_for_group?(group)).to eq(false)
    end

    it "returns true if all students in the group have earned the badge" do
      group.students.each do |s|
        create(:earned_badge, badge: new_badge, student: s, student_visible: true)
      end
      expect(unlock_condition.is_complete_for_group?(group)).to eq(true)
    end
  end

  describe "#requirements_description_sentence" do
    it "returns a sentence summarizing an assignment type unlock condition" do
      unlock_condition = UnlockCondition.new(
        condition_id: assignment_type.id, condition_type: "AssignmentType",
        condition_state: "Assignments Completed", condition_value: 21,
        unlockable_id: assignment.id, unlockable_type: "Assignment"
      )
      expect(unlock_condition.requirements_description_sentence).to \
        eq("Complete 21 assignments in the zootopian name Assignment Type")
    end

    it "returns a sentence summarizing a course unlock condition" do
      unlock_condition = UnlockCondition.new(
        condition_id: course.id, condition_type: "Course",
        condition_state: "Minimum Points Earned", condition_value: 21,
        unlockable_id: assignment.id, unlockable_type: "Assignment"
      )
      expect(unlock_condition.requirements_description_sentence).to \
        eq("Earn 21 points in this course")
    end

    it "returns a sentence summarizing an assignment pass unlock condition" do
      unlock_condition = UnlockCondition.new(
        condition_id: assignment.id, condition_type: "Assignment",
        condition_state: "Passed", condition_value: 1,
        unlockable_id: badge.id, unlockable_type: "Badge"
      )
      expect(unlock_condition.requirements_description_sentence).to \
        eq("Pass the #{ assignment.name } #{ course.assignment_term }")
    end

    it "returns a sentence summarizing a badge unlock condition" do
      expect(subject.requirements_description_sentence).to \
        eq("Earn the #{badge.name} Badge")
    end

    it "returns a summary of an assignment feedback read unlock condition" do
      unlock_condition = UnlockCondition.new(
        condition_id: assignment.id, condition_type: "Assignment",
        condition_state: "Feedback Read"
      )
      expect(unlock_condition.requirements_description_sentence).to \
        eq("Read the feedback for the #{assignment.name} Assignment")
    end

    it "returns a summary of an assignment submission unlock condition" do
      unlock_condition = UnlockCondition.new(
        condition_id: assignment.id, condition_type: "Assignment",
        condition_state: "Submitted"
      )
      expect(unlock_condition.requirements_description_sentence).to \
        eq("Submit the #{assignment.name} Assignment")
    end

    it "returns a summary of an grade earned unlock condition" do
      unlock_condition = UnlockCondition.new(
        condition_id: assignment.id, condition_type: "Assignment",
        condition_state: "Grade Earned"
      )
      expect(unlock_condition.requirements_description_sentence).to \
        eq("Earn a grade for the #{assignment.name} Assignment")
    end

    it "includes a formatted description for the condition by date if provided" do
      time_zone = "Eastern Time (US & Canada)"
      unlock_condition = UnlockCondition.new(
        condition_id: assignment.id, condition_type: "Assignment",
        condition_state: "Submitted", condition_date: Faker::Date.between(2.days.ago, Date.today)
      )
      expect(unlock_condition.requirements_description_sentence(time_zone)).to \
        eq("Submit the #{assignment.name} Assignment by #{unlock_condition.condition_date.in_time_zone(time_zone)}")
    end

    it "returns a description of a learning objective unlock condition" do
      learning_objective = build_stubbed :learning_objective, name: "Cook Ramen"
      unlock_condition = build_stubbed :unlock_condition,
        :unlock_condition_for_learning_objective,
        condition: learning_objective

      expect(unlock_condition.requirements_description_sentence).to eq \
        "Achieve the Cook Ramen Learning Objective"
    end
  end

  describe "#key_description_sentence" do
    it "returns a sentence summarizing the badge as an unlock key" do
      expect(subject.key_description_sentence).to \
        eq("Earning it unlocks the #{unlockable_assignment.name} Assignment")
    end

    it "returns a summary of an assignment feedback read unlock condition" do
      subject.condition_state = "Feedback Read"
      expect(subject.key_description_sentence).to \
        eq("Reading the feedback for it unlocks the "\
          "#{unlockable_assignment.name} Assignment")
    end

    it "returns a summary of an assignment submission unlock condition" do
      subject.condition_state = "Submitted"
      expect(subject.key_description_sentence).to \
        eq("Submitting it unlocks the #{unlockable_assignment.name} Assignment")
    end

    it "returns a summary of an grade earned unlock condition" do
      subject.condition_state = "Grade Earned"
      expect(subject.key_description_sentence).to \
        eq("Earning a grade for it unlocks the "\
          "#{unlockable_assignment.name} Assignment")
    end

    it "returns a summary of an assignment passed unlock condition" do
      subject.condition_state = "Passed"
      expect(subject.key_description_sentence).to \
        eq("Passing it unlocks the "\
          "#{unlockable_assignment.name} Assignment")
    end

    it "returns a summary of a minimum number of points earned on an Assignment as an unlock condition" do
      subject.condition_state = "Minimum Points Earned"
      subject.condition_value = 1000
      expect(subject.key_description_sentence).to \
        eq("Earning 1000 points unlocks the #{unlockable_assignment.name} Assignment")
    end

    it "returns a summary of the number of assignments completed as an unlock condition" do
      subject.condition_state = "Assignments Completed"
      subject.condition_value = 10
      expect(subject.key_description_sentence).to \
        eq("Completing 10 assignments unlocks the #{unlockable_assignment.name} Assignment")
    end
  end

  describe "#requirements_completed_sentence" do
    it "returns a statement summarizing the badge as an unlock key" do
      expect(subject.requirements_completed_sentence).to \
        eq("Earned the #{subject.name} Badge")
    end

    it "returns a summary of an assignment feedback read unlock condition" do
      subject.condition_state = "Feedback Read"
      expect(subject.requirements_completed_sentence).to \
        eq("Read the feedback for the #{ subject.name } #{ subject.condition_type }")
    end

    it "returns a summary of an assignment submission unlock condition" do
      subject.condition_state = "Submitted"
      expect(subject.requirements_completed_sentence).to \
        eq("Submitted the #{subject.name} #{ subject.condition_type }")
    end

    it "returns a summary of an grade earned unlock condition" do
      subject.condition_state = "Grade Earned"
      expect(subject.requirements_completed_sentence).to \
        eq("Earned a grade for the #{subject.name} #{ subject.condition_type }")
    end

    it "returns a summary of an assignment passed unlock condition" do
      subject.condition_state = "Passed"
      expect(subject.requirements_completed_sentence).to \
        eq("Passed the #{subject.name} #{ subject.condition_type }")
    end

    it "returns a summary of a minimum number of points earned on an Assignment as an unlock condition" do
      subject = create(:unlock_condition, condition_id: assignment.id, condition_type: "Assignment", condition_state: "Minimum Points Earned",
        unlockable_id: unlockable_assignment.id, unlockable_type: "Assignment", condition_value: 1000)
      expect(subject.requirements_completed_sentence).to \
        eq("Earned 1000 points in the #{subject.name} #{ subject.condition_type }")
    end

    it "returns a summary of the number of assignments completed as an unlock condition" do
      subject = create(:unlock_condition, condition_id: assignment_type.id, condition_type: "AssignmentType", condition_state: "Assignments Completed",
        unlockable_id: unlockable_assignment.id, unlockable_type: "Assignment", condition_value: 10)
      expect(subject.requirements_completed_sentence).to \
        eq("Completed 10 assignments in the #{subject.name} #{ subject.condition_type }")
    end

    it "returns a summary of the course requirements meant as an unlock condition" do
      subject = create(:unlock_condition, condition_id: course.id, condition_type: "Course", condition_state: "Earned",
        unlockable_id: unlockable_assignment.id, unlockable_type: "Assignment", condition_value: 10)
      expect(subject.requirements_completed_sentence).to \
        eq("Earned 10 points in this course")
    end
  end
end
