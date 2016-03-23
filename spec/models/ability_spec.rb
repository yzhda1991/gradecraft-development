require "active_record_spec_helper"
require "cancan/matchers"

describe Ability do
  let(:course) { student_course_membership.course }
  let(:student_course_membership) { create :student_course_membership }
  let(:student) { student_course_membership.user }

  subject { described_class.new(student, course) }

  context "for a Grade" do
    it "can read a grade if the GradeProctor says it can" do
      allow_any_instance_of(GradeProctor).to  \
        receive(:viewable?).with(student, course).and_return true

      expect(subject).to be_able_to(:read, Grade.new)
    end

    it "can't read a grade if the GradeProctor says it can't" do
      allow_any_instance_of(GradeProctor).to  \
        receive(:viewable?).with(student, course).and_return false

      expect(subject).to_not be_able_to(:read, Grade.new)
    end

    it "can update a grade if the GradeProctor says it can" do
      allow_any_instance_of(GradeProctor).to  \
        receive(:updatable?).with(student, course).and_return true

      expect(subject).to be_able_to(:update, Grade.new)
    end
  end

  context "for an Announcement" do
    let(:announcement) { build :announcement, course: course }

    it "is viewable by any user associated the course" do
      expect(subject).to be_able_to(:read, announcement)
    end

    it "is creatable by any staff for the course" do
      professor_course_membership = create :professor_course_membership,
        course: course
      subject = described_class.new(professor_course_membership.user, course)
      expect(subject).to be_able_to(:create, announcement)
    end

    it "is not creatable by a student" do
      expect(subject).to_not be_able_to(:create, announcement)
    end

    it "is not creatable by an instructor in another course" do
      course = create :course
      professor_course_membership = create :professor_course_membership,
        course: course
      subject = described_class.new(professor_course_membership.user, course)
      expect(subject).to_not be_able_to(:create, announcement)
    end

    it "is updatable by the author" do
      professor_course_membership = create :professor_course_membership,
        course: course
      announcement.author_id =  professor_course_membership.user_id
      subject = described_class.new(professor_course_membership.user, course)
      expect(subject).to be_able_to(:update, announcement)
    end

    it "is destroyable by the author" do
      professor_course_membership = create :professor_course_membership,
        course: course
      announcement.author_id =  professor_course_membership.user_id
      subject = described_class.new(professor_course_membership.user, course)
      expect(subject).to be_able_to(:destroy, announcement)
    end
  end

  context "for a Submission" do
    let(:assignment) { create(:assignment, course: course, grade_scope: "Individual") }
    let(:submission) { build :submission, assignment: assignment, course: course, student: student }

    it "is viewable by the student who the submission is from" do
      expect(subject).to be_able_to(:read, submission)
    end

    it "is not viewable by other students" do
      someone_else = create :user
      subject = described_class.new(someone_else, course)
      expect(subject).to_not be_able_to(:read, submission)
    end

    it "is viewable for the group of students" do
      assignment = create(:assignment, grade_scope: "Group")
      group = create :group
      group.students << student
      assignment.groups << group
      submission.assignment = assignment
      submission.group = group
      submission.student_id = nil
      expect(subject).to be_able_to(:read, submission)
    end

    it "is not viewable for students outside the group" do
      assignment = create(:assignment, grade_scope: "Group")
      group = create :group
      assignment.groups << group
      submission.assignment = assignment
      submission.group = group
      submission.student_id = nil
      expect(subject).to_not be_able_to(:read, submission)
    end

    it "is viewable by an instructor in the course" do
      professor_course_membership = create :professor_course_membership,
        course: course
      subject = described_class.new(professor_course_membership.user, course)
      expect(subject).to be_able_to(:read, submission)
    end

    it "is not viewable by an instructor in another course" do
      another_course = create :course
      professor_course_membership = create :professor_course_membership,
        course: another_course
      subject = described_class.new(professor_course_membership.user, course)
      expect(subject).to_not be_able_to(:read, submission)
    end
  end

  context "for an Assignment Weight" do
    let(:assignment_weight) { build :assignment_weight, course: course, student: student }

    it "is viewable by the student who the assignment weight is for" do
      expect(subject).to be_able_to(:read, assignment_weight)
    end

    it "is not viewable by another student" do
      course_membership = create :student_course_membership, course: course
      subject = described_class.new course_membership.user, course
      expect(subject).to_not be_able_to(:read, assignment_weight)
    end

    it "is not viewable from another course" do
      course = create :course
      subject = described_class.new student, course
      expect(subject).to_not be_able_to(:read, assignment_weight)
    end

    it "is viewable by an instructor in the course" do
      professor_course_membership = create :professor_course_membership,
        course: course
      subject = described_class.new(professor_course_membership.user, course)
      expect(subject).to be_able_to(:read, assignment_weight)
    end

    it "is not viewable by an instructor in another course" do
      another_course = create :course
      professor_course_membership = create :professor_course_membership,
        course: another_course
      subject = described_class.new(professor_course_membership.user, course)
      expect(subject).to_not be_able_to(:read, assignment_weight)
    end
  end
end
