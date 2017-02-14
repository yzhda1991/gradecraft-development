require_relative "../../app/proctors/analytics_proctor"

describe AnalyticsProctor do
  subject { described_class.new }
  let(:user) { double(:staff) }
  let(:course) { double(:course) }

  before { stub_const("MINIMUM_STUDENT_COUNT", 20) }

  context "as a staff member" do
    describe "viewable?" do
      it "returns true if the student count is less than the minimum count" do
        allow(user).to receive(:is_staff?).and_return true
        allow(course).to receive(:student_count).and_return MINIMUM_STUDENT_COUNT-1
        expect(subject.viewable? user, course).to be_truthy
      end

      it "returns true if the student count is greater than or equal to the minimum count" do
        allow(user).to receive(:is_staff?).and_return true
        allow(course).to receive(:student_count).and_return MINIMUM_STUDENT_COUNT
        expect(subject.viewable? user, course).to be_truthy
      end
    end
  end

  context "as a student" do
    describe "viewable?" do
      context "when show_analytics? for the course is true" do
        before(:each) { allow(course).to receive(:show_analytics?).and_return true }

        it "returns false if the student count is less than the minimum count" do
          allow(user).to receive(:is_staff?).and_return false
          allow(course).to receive(:student_count).and_return MINIMUM_STUDENT_COUNT-1
          expect(subject.viewable? user, course).to be_falsey
        end

        it "returns true if the student count is greater than or equal to the minimum count" do
          allow(user).to receive(:is_staff?).and_return false
          allow(course).to receive(:student_count).and_return MINIMUM_STUDENT_COUNT
          expect(subject.viewable? user, course).to be_truthy
        end
      end

      context "when show_analytics? for the course is false" do
        before(:each) { allow(course).to receive(:show_analytics?).and_return false }

        it "returns false if the student count is less than the minimum count" do
          allow(user).to receive(:is_staff?).and_return false
          expect(subject.viewable? user, course).to be_falsey
        end
      end
    end
  end
end
