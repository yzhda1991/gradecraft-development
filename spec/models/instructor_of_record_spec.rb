require "active_record_spec_helper"

describe InstructorOfRecord do
  let(:course) { create :course }
  subject { described_class.new(course) }

  describe "#initialize" do
    it "is initialized with a course" do
      expect(subject.course).to eq course
    end
  end
end
