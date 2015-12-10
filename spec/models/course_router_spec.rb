require "spec_helper"
require "./app/models/course_router"

describe CourseRouter do
  describe ".change!" do
    let(:course) { double(:course, id: 456) }
    let(:user) { double(:user, :default_course_id= => nil, save: true) }

    it "updates the default course id for the user" do
      expect(user).to receive(:default_course_id=).with(456)
      expect(user).to receive(:save)
      described_class.change! user, course
    end

    it "returns the new course" do
      result = described_class.change! user, course
      expect(result).to eq course
    end
  end
end
