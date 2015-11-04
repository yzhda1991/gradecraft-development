require "active_record_spec_helper"

describe Metric do
  subject { build(:metric) }

  describe "#copy" do
    let(:metric) { build :metric }
    subject { metric.copy }

    it "sets the default tiers to false" do
      expect(subject.add_default_tiers).to eq false
    end

    it "saves the copy if the metric is copied" do
      metric.save
      expect(subject).to_not be_new_record
    end

    it "copies the tiers" do
      metric.save
      expect(subject.tiers.count).to eq 2 # default tiers already there
      expect(subject.tiers.map(&:metric_id)).to eq [subject.id, subject.id]
    end
  end

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
