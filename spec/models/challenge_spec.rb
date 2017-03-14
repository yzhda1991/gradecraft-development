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
      subject.full_points = -100
      expect(subject).to be_invalid
    end

    it "is valid only if the open date is before the close date" do
      subject.due_at = Date.today -1
      subject.open_at = Date.today + 1
      expect(subject).to be_invalid
    end

    it "is invalid without a visibility setting" do
      subject.visible = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:visible]).to include "must be true or false"
    end

    it "is invalid without a submission setting" do
      subject.accepts_submissions = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:accepts_submissions]).to include "must be true or false"
    end

    it "is invalid without a release setting" do
      subject.release_necessary = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:release_necessary]).to include "must be true or false"
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
end
