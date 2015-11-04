require "active_record_spec_helper"

describe Tier do
  describe "#copy" do
    let(:tier) { build :tier }
    subject { tier.copy }

    it "copies the badges for the tiers" do
      tier.save
      tier.badges.create! name: "Blah", course: create(:course)
      expect(subject.badges.size).to eq 1
      expect(subject.tier_badges.map(&:tier_id)).to eq [subject.id]
    end
  end
end
