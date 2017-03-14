describe CourseMembership do
  subject { build :course_membership }

  context "validations" do

    it "is valid with a user, a course and a role" do
      expect(subject).to be_valid
    end

    it "requires a course" do
      subject.course = nil
      expect(subject).to_not be_valid
    end

    it "requires a student" do
      subject.user = nil
      expect(subject).to_not be_valid
    end

    it "requires a role" do
      subject.role = nil
      expect(subject).to_not be_valid
    end

  end

end
