require "active_record_spec_helper"

describe Challenge do
  subject { build(:challenge) }

  describe "validations" do
    it "is valid" do
      expect(subject).to be_valid
    end
    it "is invalid without a name" do
      subject.name = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:name]).to include "can't be blank"
    end

    it "is invalid without a course" do
      subject.course = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:course]).to include "can't be blank"
    end

    it "is valid only with positive_points" do
      subject.point_total = -100
      expect(subject).to be_invalid
    end

    it "is valid only if the open date is before the close date" do
      subject.due_at = Date.today -1
      subject.open_at = Date.today + 1
      expect(subject).to be_invalid
    end
  end

  describe "#copy" do
    let(:challenge) { build :challenge }
    subject { challenge.copy }

    it "makes a duplicated copy of itself" do
      expect(subject).to_not eq challenge
    end
  end

  describe "#has_levels?" do
    it "returns true if challenge score levels are present" do
      create(:challenge_score_level, challenge: subject)
      expect(subject.has_levels?).to be(true)
    end

    it "returns false if score levels are not present" do
      expect(subject.has_levels?).to be(false)
    end
  end

  describe "#mass_grade?" do
    it "returns true if mass grade is turned on" do
      subject.mass_grade = true
      expect(subject.mass_grade?).to be(true)
    end

    it "returns false if the mass grade is off" do
      subject.mass_grade = false
      expect(subject.mass_grade?).to be(true)
    end
  end

  describe "#challenge_grade_for_team(team)" do
    it "returns the grade for team if present" do
      team = create(:team)
      challenge_grade = create(:challenge_grade, challenge: subject, team: team)
      expect(subject.challenge_grade_for_team(team)).to eq(challenge_grade)
    end

    it "returns nil if not grade present" do
      team = create(:team)
      expect(subject.challenge_grade_for_team(team)).to eq(nil)
    end
  end

  describe "#future?" do
    it "returns true if due date is after today" do
      subject.due_at = Date.today + 1
      expect(subject.future?).to be(true)
    end

    it "returns false if there is no due date" do
      subject.due_at = nil
      expect(subject.future?).to be(false)
    end

    it "returns false if the due date is in the past" do
      subject.due_at = Date.today - 1
      expect(subject.future?).to be(false)
    end

  end

  describe "#graded?" do
    it "returns true if challenge grades are present" do
      create(:challenge_grade, challenge: subject)
      expect(subject.graded?).to be(true)
    end

    it "returns false if no challenge grades are present" do
      expect(subject.graded?).to be(false)
    end
  end

  describe "#visible_for_student?(student)" do
    it "returns true if challenge is visible" do
      subject.visible = true
      expect(subject.visible?).to be(true)
    end

    it "returns false if the challenge is invisible" do
      subject.visible = false
      expect(subject.visible?).to be(false)
    end
  end

  describe "#find_or_create_predicted_earned_challenge(student)" do
    skip "implement"
    #PredictedEarnedChallenge.where(student: student, challenge: self).first || PredictedEarnedChallenge.create(student_id: student.id, challenge_id: self.id)
  end


end
