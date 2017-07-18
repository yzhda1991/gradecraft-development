describe ChallengeGrade do
  subject { build(:challenge_grade) }

  context "validations" do
    it "is valid with a team, and a challenge" do
      expect(subject).to be_valid
    end

    it "is invalid without a team" do
      subject.team = nil
      expect(subject).to be_invalid
    end

    it "is invalid without a challenge" do
      subject.challenge = nil
      expect(subject).to be_invalid
    end
  end

  describe "#score" do
    it "returns the challenge grade score if present" do
      challenge_grade = create(:challenge_grade, raw_points: 100)
      expect(challenge_grade.score).to eq(100)
    end

    it "returns nil if there's no score present" do
      challenge_grade = create(:challenge_grade, raw_points: nil)
      expect(challenge_grade.score).to eq(nil)
    end
  end

  describe "calculation of final_points" do
    it "is nil when score is nil" do
      subject.update(raw_points: nil)
      expect(subject.final_points).to eq(nil)
    end

    it "is the sum of score and adjustment_points" do
      subject.update(raw_points: "1234", adjustment_points: -234)
      expect(subject.final_points).to eq(1000)
    end
  end

  describe "#cache_team_score" do
    it "saves the team scores" do
      team = create(:team, challenge_grade_score: 0, average_score: 0)
      challenge_grade = create(:student_visible_challenge_grade, team: team, raw_points: 100)
      challenge_grade.cache_team_scores
      expect(team.challenge_grade_score).to eq(100)
    end
  end
end
