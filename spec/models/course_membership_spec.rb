require "active_record_spec_helper"

describe CourseMembership do
  describe ".create_course_membership_from_lti" do
    let(:user) { build_stubbed(:user) }
    let(:course) { build_stubbed(:course) }

    context "when there is no context role" do
      let(:auth_hash) { { "extra" => { "raw_info" => { "roles" => "" }}} }

      it "creates a new course membership" do
        expect{ CourseMembership.create_course_membership_from_lti(user, course, auth_hash) }.to \
          change { CourseMembership.count }.by(1)
      end

      it "sets the default course membership role" do
        CourseMembership.create_course_membership_from_lti(user, course, auth_hash)
        course_membership = CourseMembership.unscoped.last
        expect(course_membership.role).to eq "observer"
      end
    end

    context "when there is a context role" do
      let(:auth_hash) { { "extra" => { "raw_info" => { "roles" => "instructor" }}} }

      it "creates a new course membership" do
        expect{ CourseMembership.create_course_membership_from_lti(user, course, auth_hash) }.to \
          change { CourseMembership.count }.by(1)
      end

      it "sets the course membership role" do
        CourseMembership.create_course_membership_from_lti(user, course, auth_hash)
        course_membership = CourseMembership.unscoped.last
        expect(course_membership.role).to eq "professor"
      end
    end

    context "when the authorization hash is invalid" do
      let(:auth_hash) { { "extra" => { "raw_info": nil }} }

      it "does not create a course membership" do
        expect{ CourseMembership.create_course_membership_from_lti(user, course, auth_hash) }.to_not \
          change(CourseMembership, :count)
      end
    end
  end

  describe ".instructors_of_record" do
    let!(:instructor_membership) { create :course_membership, :staff, instructor_of_record: true }
    let!(:staff_membership) { create :course_membership, :staff, instructor_of_record: false }

    it "returns all memberships that have the instructor of record turned on" do
      expect(described_class.instructors_of_record).to eq [instructor_membership]
    end
  end
end
