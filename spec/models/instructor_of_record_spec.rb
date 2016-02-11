require "active_record_spec_helper"

describe InstructorOfRecord do
  let(:course) { create :course }
  subject { described_class.new(course) }

  describe "#initialize" do
    it "is initialized with a course" do
      expect(subject.course).to eq course
    end
  end

  describe "#update_course_memberships" do
    context "for new instructors of record" do
      let(:membership) { create :staff_course_membership, course: course }

      it "adds instructors of record to the course membership" do
        memberships = InstructorOfRecord.new(course).update_course_memberships([membership.user_id])

        expect(course.instructors_of_record).to eq [membership.user]
        expect(memberships.map(&:id)).to eq [membership.id]
      end
    end
  end
end
