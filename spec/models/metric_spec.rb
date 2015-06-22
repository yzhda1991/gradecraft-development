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
        pp @metric.tiers
        @metric.tiers.count.should == 0
      end
    end

    context "metric isn't flagged as duplicated" do
      it "should create tiers" do
        @metric.add_default_tiers = true
        @metric.save
        @metric.tiers.count.should == 2
      end
    end

    context "default" do
      it "should create default tiers" do
        @metric = create(:metric)
        @metric.tiers.count.should == 2
      end
    end
  end
end
