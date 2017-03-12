describe Badges::IndexPresenter do
  let(:badge) do
    double(:badge,
      name: "Badgerino",
      earned_count: "course count")
  end

  let(:student) do
    double(:student,
      visible_earned_badges_for_badge_count: "student count")
  end

  let(:teams) { double(:teams, find_by: "Team A") }
  let(:params) {{ team_id: 123 }}

  subject do
    Badges::IndexPresenter.new(
      { badges: [badge],
        title: "Badgerinos",
        student: student
      }
    )
  end

  describe "#badges" do
    it "is the badges that are passed in as a property" do
      expect(subject.badges).to eq [badge]
    end
  end

  describe "#student" do
    it "is the student that is passed in as a property" do
      expect(subject.student).to eq student
    end
  end

  describe "#earned_badges_count" do
    it "returns students earned badges count if student present" do
      expect(subject.earned_badges_count(badge)).to eq("student count")
    end

    it "returns all earned badges for badge count when student is absent" do
      subject = Badges::IndexPresenter.new(badge: badge)
      expect(subject.earned_badges_count(badge)).to eq("course count")
    end
  end
end
