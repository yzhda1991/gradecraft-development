require "active_record_spec_helper"

describe Timeline do
  let(:course) { create :course }

  describe "#initialize" do
    it "is initialized with a course" do
      expect(described_class.new(course).course).to eq course
    end
  end
end
