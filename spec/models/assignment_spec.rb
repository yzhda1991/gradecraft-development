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
  end

  describe "pass-fail assignments" do
    it "sets point total to zero on save" do
      subject.point_total = 3000
      subject.pass_fail = true
      subject.save
      expect(subject.point_total).to eq(0)
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
