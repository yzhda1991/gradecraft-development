require 'spec_helper'

describe Metric do
  before(:each) do
    @metric = build(:metric)
  end

  context "creation" do
    context "metric is flagged as duplicated" do
      it "should not create tiers" do
        @metric.add_default_tiers = false
        @metric.save
        expect(@metric.tiers.count).to eq(0)
      end
    end

    context "metric isn't flagged as duplicated" do
      it "should create tiers" do
        @metric.add_default_tiers = true
        @metric.save
        expect(@metric.tiers.count).to eq(2)
      end
    end

    context "default" do
      it "should create default tiers" do
        @metric = create(:metric)
        expect(@metric.tiers.count).to eq(2)
      end
    end
  end
end
