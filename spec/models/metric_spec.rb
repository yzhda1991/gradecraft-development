require "active_record_spec_helper"

describe Metric do
  subject { build(:metric) }

  context "creation" do
    context "metric is flagged as duplicated" do
      it "should not create tiers" do
        subject.add_default_tiers = false
        subject.save
        expect(subject.tiers.count).to eq(0)
      end
    end

    context "metric isn't flagged as duplicated" do
      it "should create tiers" do
        subject.add_default_tiers = true
        subject.save
        expect(subject.tiers.count).to eq(2)
      end
    end

    context "default" do
      it "should create default tiers" do
        subject = create(:metric)
        expect(subject.tiers.count).to eq(2)
      end
    end
  end
end
