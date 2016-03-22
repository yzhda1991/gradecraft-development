require "active_record_spec_helper"
require "cancan/matchers"

describe Ability do
  let(:course) { course_membership.course }
  let(:course_membership) { create :student_course_membership }
  let(:student) { course_membership.user }

  subject { described_class.new(student, course) }

  context "for a Grade" do
    it "can read a grade if the GradeProctor says it can" do
      allow_any_instance_of(GradeProctor).to  \
        receive(:viewable?).with(student, course).and_return true

      expect(subject).to be_able_to(:read, Grade.new)
    end

    it "can't read a grade if the GradeProctor says it can't" do
      allow_any_instance_of(GradeProctor).to  \
        receive(:viewable?).with(student, course).and_return false

      expect(subject).to_not be_able_to(:read, Grade.new)
    end

    it "can update a grade if the GradeProctor says it can" do
      allow_any_instance_of(GradeProctor).to  \
        receive(:updatable?).with(student, course).and_return true

      expect(subject).to be_able_to(:update, Grade.new)
    end
  end
end
