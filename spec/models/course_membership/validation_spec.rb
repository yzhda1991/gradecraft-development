require "active_record_spec_helper"

describe CourseMembership do
  subject { build :course_membership }

  describe "validations" do
    describe "#student?" do
      it "is a student if the role is student" do
        subject.role = "student"
        expect(subject).to be_student
      end
    end

    describe "#professor?" do
      it "is a professor if the role is professor" do
        subject.role = "professor"
        expect(subject).to be_professor
      end
    end

    describe "#gsi?" do
      it "is a gsi if the role is gsi" do
        subject.role = "gsi"
        expect(subject).to be_gsi
      end
    end

    describe "#admin?" do
      it "is an admin if the role is admin" do
        subject.role = "admin"
        expect(subject).to be_admin
      end
    end

    describe "#staff?" do
      it "is staff if it has a professor, gsi, or admin role" do
        roles = ["professor", "gsi", "admin"]
        roles.each do |role|
          subject.role = role
          expect(subject).to be_staff
        end
      end

      it "is not staff if it has a student role" do
        subject.role = "student"
        expect(subject).to_not be_staff
      end
    end
  end
end
