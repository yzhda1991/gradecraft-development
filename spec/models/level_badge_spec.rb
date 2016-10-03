require "active_record_spec_helper"

describe LevelBadge do
  let(:level_badge) { create :level_badge }

  describe "#copy" do
    subject { level_badge.copy }

    it "makes a duplicated copy of itself" do
      expect(subject).to_not eq level_badge
    end
  end
end
