require "rails_spec_helper"

describe Level do
  describe "#copy" do
    let(:level) { build :level }
    subject { level.copy }

    it "copies the badges for the levels" do
      level.save
      level.badges.create! name: "Blah", course: create(:course)
      expect(subject.badges.size).to eq 1
      expect(subject.level_badges.map(&:level_id)).to eq [subject.id]
    end
  end
end
