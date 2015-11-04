require "active_record_spec_helper"

describe Rubric do
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
end
