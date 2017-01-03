require "active_record_spec_helper"

describe CourseMembership do
  describe ".instructors_of_record" do
    let!(:instructor_membership) { create :course_membership, :staff, instructor_of_record: true }
    let!(:staff_membership) { create :course_membership, :staff, instructor_of_record: false }

    it "returns all memberships that have the instructor of record turned on" do
      expect(described_class.instructors_of_record).to eq [instructor_membership]
    end
  end
end
