require "active_record_spec_helper"

describe AssignmentWeight do

  let(:student) { create(:user) }

  let(:subject) { create(:assignment_weight, student: student) }

  context "validations" do

    it "is valid with a student, assignment, assignment_type, a weight, and course" do
      expect(subject).to be_valid
    end

    it "is invalid without a student" do
      subject.student = nil
      expect(subject).to be_invalid
    end

    it "is invalid without a weight" do
      subject.weight = nil
      expect(subject).to be_invalid
    end
  end

  describe ".for_course" do
    it "returns all assignment weights for a specific course" do
      course = create(:course)
      course_assignment_weight = create(:assignment_weight, course: course)
      another_assignment_weight = create(:assignment_weight)
      results = AssignmentWeight.for_course(course)
      expect(results).to eq [course_assignment_weight]
    end
  end

  describe ".for_student" do
    it "returns all assignment weights for a specific student" do
      student = create(:user)
      student_assignment_weight = create(:assignment_weight, student: student)
      another_assignment_weight = create(:assignment_weight)
      results = AssignmentWeight.for_student(student)
      expect(results).to eq [student_assignment_weight]
    end
  end

  describe "#updatable_by?(user)" do
    it "returns true for the student whose weight it is" do
      expect(subject.updatable_by?(student)).to eq(true)
    end

    it "returns false for any other student" do
      student_2 = create(:user)
      expect(subject.updatable_by?(student_2)).to eq(false)
    end
  end

  describe "#destroyable_by?(user)" do
    it "returns true for the student whose weight it is" do
      expect(subject.destroyable_by?(student)).to eq(true)
    end

    it "returns false for any other studnet" do
      student_2 = create(:user)
      expect(subject.destroyable_by?(student_2)).to eq(false)
    end
  end

  describe "#viewable_by?(user)" do
    it "returns true for the student whose weight it is" do
      expect(subject.viewable_by?(student)).to eq(true)
    end

    it "returns false for any other student" do
      student_2 = create(:user)
      expect(subject.viewable_by?(student_2)).to eq(false)
    end
  end

end
