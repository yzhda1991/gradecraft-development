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
