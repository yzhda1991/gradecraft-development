describe ScoreLevel do
  let(:challenge) {create :challenge}
  subject { build(:challenge_score_level, challenge: challenge) }

  # Should work for both challenge score levels and assignment score levels
  describe "#formatted_name" do
    it "returns the level name followed by the point values in parentheses" do
      subject.name = "Level Name"
      subject.points = 10000
      expect(subject.formatted_name).to eq("Level Name (10000 points)")
    end
  end
end
