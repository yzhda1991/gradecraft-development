require "active_record_spec_helper"

describe Course do
  subject { build(:course) }
  let(:staff_membership) { create :staff_course_membership, course: subject, instructor_of_record: true }

  describe "validations" do
    it "requires a name" do
      subject.name = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:name]).to include "can't be blank"
    end

    it "requires a course number" do
      subject.courseno = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:courseno]).to include "can't be blank"
    end
  end

  describe "#students_being_graded" do
    it "returns an alphabetical list of students being graded" do
      student = create(:user, last_name: 'Zed')
      student.courses << subject
      student2 = create(:user, last_name: 'Alpha')
      student2.courses << subject
      expect(subject.students_being_graded).to eq([student2,student])
    end
  end

  it "returns Pass and Fail as defaults for pass_term and fail_term" do
    expect(subject.pass_term).to eq("Pass")
    expect(subject.fail_term).to eq("Fail")
  end

  describe ".active" do
    it "returns courses that have a status" do
      Course.destroy_all
      active = create :course, status: true
      inactive = create :course, status: false
      expect(Course.active.to_a).to eq [active]
    end
  end

  describe ".inactive" do
    it "returns courses that do not have a status" do
      Course.destroy_all
      active = create :course, status: true
      inactive = create :course, status: false
      expect(Course.inactive.to_a).to eq [inactive]
    end
  end

  describe "#instructors_of_record" do
    it "returns all the staff who are instructors of record for the course" do
      membership = create :staff_course_membership, course: subject, instructor_of_record: true
      expect(subject.instructors_of_record).to eq [membership.user]
    end
  end

  describe "#instructors_of_record_ids=" do
    it "adds the instructors of record if they were not there before" do
      membership = create :staff_course_membership, course: subject
      subject.instructors_of_record_ids = [membership.user_id]
      expect(subject.instructors_of_record).to eq [membership.user]
    end

    it "removes the instructors of record that are not present" do
      membership = staff_membership
      subject.instructors_of_record_ids = []
      expect(subject.instructors_of_record).to be_empty
    end
  end

  it "automatically assigns memberships to admins after the course is created" do
    admin = create :user, admin: true
    course = create :course
    expect(CourseMembership.where(user_id: admin.id, course_id: course.id, role: "admin")).to be_exist
  end

  let(:course1) { create(:course) }
  let(:course2) { create(:course) }
  let(:staff_membership) { create :staff_course_membership, course: course1, instructor_of_record: true }
  let(:student_membership1) { create :student_course_membership, course: course1 }
  let(:student_membership2) { create :student_course_membership, course: course1 }
  let(:student_membership3) { create :student_course_membership, course: course2 }


  describe "recalculate_student_scores" do
    subject { course1.recalculate_student_scores }

    context "student ids present" do
      it "creates a score recalculator job for each student" do
      end
    end

    context "no student ids present" do
      it "creates creates no score recalculator jobs" do
      end
    end
  end


  describe "ordered_student_ids" do
    subject { course1.ordered_student_ids }

    before do
      CourseMembership.where(course_id: course1.id).destroy_all
      @student_membership1 = student_membership1
      @student_membership2 = student_membership2
      @student_membership3 = student_membership3
      @staff_membership = staff_membership
    end

    it "should order the ids by users.id ASC" do
      expect(subject).to eq([@student_membership1.user_id, @student_membership2.user_id])
    end

    it "should only return an array of ids" do
      expect(subject.collect(&:class)).to eq([Fixnum, Fixnum])
    end

    context "user is a student not in the course" do
      it "doesn't include the student's id" do
        expect(subject).not_to include(@student_membership3.user_id)
      end
    end

    context "user is a student in the course" do
      it "includes the student's id" do
        expect(subject).to include(@student_membership1.user_id)
        expect(subject).to include(@student_membership2.user_id)
      end
    end

    context "user is a professor in the course" do
      it "doesn't include the student's id" do
        expect(subject).not_to include(@staff_membership.user_id)
      end
    end
  end
end
