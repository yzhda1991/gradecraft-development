require "active_record_spec_helper"

describe Assignment do
  subject { build(:assignment) }

  context "validations" do
    it "is valid with a name and assignment type" do
      expect(subject).to be_valid
    end

    it "is invalid without a name" do
      subject.name = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:name]).to include "can't be blank"
    end

    it "is invalid without an assignment type" do
      subject.assignment_type_id = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:assignment_type_id]).to include "can't be blank"
    end

    it "is invalid without a course" do
      subject.course_id = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:course_id]).to include "can't be blank"
    end
  end

  describe "#earned_score_count" do
    before { subject.save }

    it "returns only graded or released grades" do
      subject.grades.create student_id: create(:user).id
      expect(subject.earned_score_count).to be_empty
    end

    it "returns the number of unique scores for each grade" do
      subject.grades.create student_id: create(:user).id, raw_score: 85,
        status: "Graded"
      subject.grades.create student_id: create(:user).id, raw_score: 85,
        status: "Graded"
      subject.grades.create student_id: create(:user).id, raw_score: 105,
        status: "Graded"
      expect(subject.earned_score_count).to eq({ 85 => 2, 105 => 1 })
    end
  end

  describe "#percentage_score_earned" do
    before { subject.save }

    it "returns the earned scores with a scores key" do
      subject.grades.create student_id: create(:user).id, raw_score: 85,
        status: "Graded"
      subject.grades.create student_id: create(:user).id, raw_score: 85,
        status: "Graded"
      subject.grades.create student_id: create(:user).id, raw_score: 105,
        status: "Graded"
      expect(subject.percentage_score_earned).to \
        eq({ scores: [{ data: 1, name: 105 }, { data: 2, name: 85 }]})
    end
  end

  describe "pass-fail assignments" do
    it "sets point total to zero on save" do
      subject.point_total = 3000
      subject.pass_fail = true
      subject.save
      expect(subject.point_total).to eq(0)
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

  describe "#check_unlock_status" do
    let(:student) { create :user }
    before { subject.save }

    it "returns a new unlock state if the goal of unlockables does not meet the number of unlocks" do
      subject.unlock_conditions.create! condition_id: subject.id,
        condition_type: subject.class, condition_state: "Blah"
      expect(subject.check_unlock_status(student)).to be_an_instance_of UnlockState
      expect(subject.unlock_states.last).to_not be_unlocked
    end

    context "when the number of conditions are met" do
      it "returns the updated unlock state when it is found" do
        condition = subject.unlock_conditions.create condition_id: subject.id,
          condition_type: subject.class, condition_state: "Blah"
        allow(condition).to receive(:is_complete?).with(student).and_return true
        state = subject.unlock_states.create(student_id: student.id,
                                             unlocked: false)
        expect(subject.check_unlock_status(student)).to eq state
        expect(state.reload).to be_unlocked
      end

      it "returns a new unlock state if it did not exist" do
        condition = subject.unlock_conditions.create condition_id: subject.id,
          condition_type: subject.class, condition_state: "Blah"
        allow(condition).to receive(:is_complete?).with(student).and_return true
        expect(subject.check_unlock_status(student)).to eq \
          subject.unlock_states.last
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
          condition_type: subject.class, condition_state: "Blah"
      expect(subject.unlock_condition_count_met_for(student)).to be_zero
    end

    it "returns the number of conditions that were complete for the student" do
      met_condition = subject.unlock_conditions.create condition_id: subject.id,
          condition_type: subject.class, condition_state: "Blah"
      allow(met_condition).to receive(:is_complete?).with(student).and_return true
      condition = subject.unlock_conditions.create condition_id: subject.id,
          condition_type: subject.class, condition_state: "Blah"
      expect(subject.unlock_condition_count_met_for(student)).to eq 1
    end
  end

  describe "#copy" do
    let(:assignment) { build :assignment }
    subject { assignment.copy }

    it "prepends the name with 'Copy of'" do
      assignment.name = "Table of elements"
      expect(subject.name).to eq "Copy of Table of elements"
    end

    it "makes a shallow copy of the fields" do
      assignment.description = "This is a great assignment"
      expect(subject.description).to eq "This is a great assignment"
    end

    it "saves the copy if the assignment is saved" do
      assignment.save
      expect(subject).to_not be_new_record
    end

    it "copies the assignment score levels" do
      assignment.save
      assignment.assignment_score_levels.create
      expect(subject.assignment_score_levels.size).to eq 1
      expect(subject.assignment_score_levels.map(&:assignment_id)).to eq [subject.id]
    end

    it "copies the rubric" do
      assignment.save
      assignment.build_rubric
      expect(subject.rubric.assignment_id).to eq subject.id
      expect(subject.rubric).to_not be_new_record
    end
  end

  describe "#future?" do
    it "is not for the future if there is no due date" do
      subject.due_at = nil
      expect(subject).to_not be_future
    end

    it "is not for the future if the due date is in the past" do
      subject.due_at = 2.days.ago
      expect(subject).to_not be_future
    end

    it "is for the future if the due date is in the future" do
      subject.due_at = 2.days.from_now
      expect(subject).to be_future
    end
  end

  describe "#soon?" do
    it "is not soon if there is no due date" do
      subject.due_at = nil
      expect(subject).to_not be_soon
    end

    it "is not soon if the due date is too far in the future" do
      subject.due_at = 8.days.from_now
      expect(subject).to_not be_soon
    end

    it "is soon if the due date is within 7 days from now" do
      subject.due_at = 2.days.from_now
      expect(subject).to be_soon
    end
  end

  describe "#opened?" do
    it "is opened if there is no open at date set" do
      subject.open_at = nil
      expect(subject).to be_opened
    end

    it "is opened if the open at date is in the past" do
      subject.open_at = 2.days.ago
      expect(subject).to be_opened
    end

    it "is not opened if the assignment opens in the future" do
      subject.open_at = 2.days.from_now
      expect(subject).to_not be_opened
    end
  end

  describe "#overdue?" do
    it "is not overdue if there is no due date" do
      subject.due_at = nil
      expect(subject).to_not be_overdue
    end

    it "is not overdue if the due date is in the future" do
      subject.due_at = 2.days.from_now
      expect(subject).to_not be_overdue
    end

    it "is overdue if the due date has past" do
      subject.due_at = 2.days.ago
      expect(subject).to be_overdue
    end
  end

  describe "#accepting_submissions?" do
    it "is accepting submissions if no acceptance date was set" do
      subject.accepts_submissions_until = nil
      expect(subject).to be_accepting_submissions
    end

    it "is accepting submissions if the acceptance date is in the future" do
      subject.accepts_submissions_until = 2.days.from_now
      expect(subject).to be_accepting_submissions
    end

    it "is not accepting submissions if the acceptance date was in the past" do
      subject.accepts_submissions_until = 2.days.ago
      expect(subject).to_not be_accepting_submissions
    end
  end

  describe "#open?" do
    before do
      subject.open_at = 4.days.ago
      subject.due_at = 2.days.ago
      subject.accepts_submissions_until = 2.days.ago
    end

    it "is open if there is no open date and there is no due date" do
      subject.open_at = nil
      subject.due_at = nil
      expect(subject).to be_open
    end

    it "is open if the open date has passed but there is no due date" do
      subject.due_at = nil
      expect(subject).to be_open
    end

    it "is open if there is no open date but there is a future due date" do
      subject.open_at = nil
      subject.due_at = 2.days.from_now
      expect(subject).to be_open
    end

    it "is open if there is no open date, the due date has passed and it does not have an accept date" do
      subject.open_at = nil
      subject.accepts_submissions_until = nil
      expect(subject).to be_open
    end

    it "is open if there is no open date, the due date has passed and it has a future accept date" do
      subject.open_at = nil
      subject.accepts_submissions_until = 2.days.from_now
      expect(subject).to be_open
    end

    it "is open if there is a previous open date, a future due date and it does not have an accept date" do
      subject.open_at = nil
      subject.due_at = 2.days.from_now
      subject.accepts_submissions_until = nil
      expect(subject).to be_open
    end

    it "is open if there is a previous open date, a previous due date and it does not have an accept date" do
      subject.accepts_submissions_until = nil
      expect(subject).to be_open
    end

    it "is open if there is a previous open date and a future accept date" do
      subject.accepts_submissions_until = 2.days.from_now
      expect(subject).to be_open
    end
  end
end
