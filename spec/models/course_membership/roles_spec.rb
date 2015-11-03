require "active_record_spec_helper"

describe CourseMembership do
  subject { build :course_membership }

  describe "roles" do
    it "requires that the role is a staff role for instructors of record" do
      subject.role = "student"
      subject.instructor_of_record = true
      expect(subject).to_not be_valid
      expect(subject.errors[:instructor_of_record]).to include "is not valid for students"
    end

    it "requires that a role is specified if the instructor of record is set" do
      subject.role = nil
      subject.instructor_of_record = true
      expect(subject).to_not be_valid
      expect(subject.errors[:instructor_of_record]).to include "is not valid for anyone"
    end
  end
end
