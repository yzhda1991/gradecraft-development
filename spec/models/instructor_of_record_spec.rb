require "active_record_spec_helper"

describe InstructorOfRecord do
  let(:course) { create :course }
  subject { described_class.new(course) }

  describe "#initialize" do
    it "is initialized with a course" do
      expect(subject.course).to eq course
    end
  end

  describe "#users" do
    let!(:membership) { create :staff_course_membership, course: course, instructor_of_record: true }

    it "returns the users that are marked as instructors of record for the course" do
      expect(subject.users).to eq [membership.user]
    end
  end

  describe "#update_course_memberships" do
    let(:membership) { create :staff_course_membership, course: course }

    context "for new instructors of record" do
      it "adds instructors of record to the course membership" do
        InstructorOfRecord.new(course).update_course_memberships([membership.user_id])

        expect(course.instructors_of_record).to eq [membership.user]
      end
    end

    context "for existing instructors of record" do
      it "removes instructors of record to the course membership if they are not included" do
        membership.update_attributes instructor_of_record: true
        memberships = InstructorOfRecord.new(course).update_course_memberships([])

        expect(course.instructors_of_record).to be_empty
        expect(memberships.map(&:id)).to be_empty
      end
    end

    it "returns all the course memberships that have instructors of record" do
      membership1 = create :staff_course_membership, course: course, instructor_of_record: true
      membership2 = create :staff_course_membership, course: course, instructor_of_record: true
      result = subject.update_course_memberships [membership1.user_id, membership2.user_id]
      expect(result).to eq [membership1, membership2]
    end
  end
end
