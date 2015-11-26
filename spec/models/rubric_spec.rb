require "active_record_spec_helper"

describe Rubric do

  describe "validations" do 
    let(:rubric) { build :rubric}

    it "is valid with an assignment" do 
      expect(rubric).to be_valid
    end 

    it "is invalid without an assignment" do 
      rubric.assignment = nil
      expect(rubric).to be_invalid
    end
  end 

  describe "#copy" do
    let(:rubric) { build :rubric }
    subject { rubric.copy }

    it "copies the metrics" do
      rubric.save
      rubric.metrics.create max_points: 10_000, name: "Metric ton", order: 1
      expect(subject.metrics.size).to eq 1
      expect(subject.metrics.map(&:rubric_id)).to eq [subject.id]
    end
  end

  describe "#max_tier_count" do 
    let(:rubric) { build :rubric }

    it "returns the maximum number of tiers present for any metric" do 
      metric_1 = create(:metric, rubric: rubric) 
      metric_2 = create(:metric, rubric: rubric)
      tier_1 = create(:tier, metric: metric_1)
      tier_2 = create(:tier, metric: metric_1)
      tier_3 = create(:tier, metric: metric_1)

      #count is the number created + the zero credit and the max credit
      expect(rubric.max_tier_count).to eq(5)
    end
  end

  describe "#designed?" do
    let(:rubric) { build :rubric }

    it "returns true if metrics are present" do 
      metric = create(:metric, rubric: rubric)

      expect(rubric.designed?).to eq(true)
    end

    it "returns false if metrics are not present" do 
      expect(rubric.designed?).to eq(false)
    end
  end

end
