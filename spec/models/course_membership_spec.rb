require "active_record_spec_helper"

describe CourseMembership do
  describe "#copy" do
    let(:course_membership) { build :course_membership }
    subject { course_membership.copy }

    it "makes a duplicated copy of itself" do
      expect(subject).to_not eq course_membership
    end

    it "overrides the specified attributes" do
      attributes = { role: "some other role" }
      subject = course_membership.copy attributes
      expect(subject.role).to eq attributes[:role]
    end

    it "resets the values for the scores" do
      course_membership = build_stubbed :course_membership, score: 0
      subject = course_membership.copy
      expect(subject.score).to be_zero
    end
  end

  describe ".create_or_update_from_lti" do
    let(:user) { build_stubbed(:user) }
    let(:course) { create(:course) }

    context "when there is no context role" do
      let(:auth_hash) { { "extra" => { "raw_info" => { "roles" => "" }}} }

      context "when no prior course membership exists" do
        it "update the existing course membership" do
          expect{ CourseMembership.create_or_update_from_lti(user, course, auth_hash) }.to \
            change { CourseMembership.count }.by(1)
        end

        it "sets the default course membership role" do
          CourseMembership.create_or_update_from_lti(user, course, auth_hash)
          course_membership = CourseMembership.unscoped.last
          expect(course_membership.role).to eq "observer"
        end
      end

      context "when there is a prior course membership" do
        let!(:course_membership) { create(:course_membership, user: user, course: course) }

        it "does not create a new course membership" do
          expect{ CourseMembership.create_or_update_from_lti(user, course, auth_hash) }.to_not \
            change(CourseMembership, :count)
        end
      end
    end

    context "when there is a context role" do
      let(:auth_hash) { { "extra" => { "raw_info" => { "roles" => "instructor" }}} }

      context "when no prior course membership exists" do
        it "creates a new course membership" do
          expect{ CourseMembership.create_or_update_from_lti(user, course, auth_hash) }.to \
            change { CourseMembership.count }.by(1)
        end

        it "sets the course membership role" do
          CourseMembership.create_or_update_from_lti(user, course, auth_hash)
          course_membership = CourseMembership.unscoped.last
          expect(course_membership.role).to eq "professor"
        end
      end

      context "when there is a prior course membership" do
        let!(:course_membership) { create(:course_membership, user: user, course: course) }

        it "does not create a new course membership" do
          expect{ CourseMembership.create_or_update_from_lti(user, course, auth_hash) }.to_not \
            change(CourseMembership, :count)
        end

        it "updates the course membership role" do
          CourseMembership.create_or_update_from_lti(user, course, auth_hash)
          course_membership = CourseMembership.unscoped.last
          expect(course_membership.role).to eq "professor"
        end
      end
    end

    context "when the authorization hash is invalid" do
      let(:auth_hash) { { "extra" => { "raw_info": nil }} }

      it "does not create a course membership" do
        expect{ CourseMembership.create_or_update_from_lti(user, course, auth_hash) }.to_not \
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
