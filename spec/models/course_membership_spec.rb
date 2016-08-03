require "active_record_spec_helper"

describe CourseMembership do
  describe ".instructors_of_record" do
    it "returns all memberships that have the instructor of record turned on" do
      let!(:instructor_membership) { create :staff_course_membership, instructor_of_record: true }
      let!(:staff_membership) { create :staff_course_membership, instructor_of_record: false }
      expect(described_class.instructors_of_record).to eq [instructor_membership]
    end
  end
end
