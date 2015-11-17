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

    it "requires a numeric for max group size" do
      subject.max_group_size = "a"
      expect(subject).to_not be_valid
      expect(subject.errors[:max_group_size]).to include "is not a number"
    end

    it "allows for a nil max group size" do
      subject.max_group_size = nil
      expect(subject).to be_valid
      expect(subject.errors[:max_group_size]).to be_empty
    end

    it "requires the max group size to be greater than 0" do
      subject.max_group_size = 0
      expect(subject).to_not be_valid
      expect(subject.errors[:max_group_size]).to include "must be greater than or equal to 1"
    end

    it "requires a numeric for min group size" do
      subject.min_group_size = "a"
      expect(subject).to_not be_valid
      expect(subject.errors[:min_group_size]).to include "is not a number"
    end

    it "allows for a nil min group size" do
      subject.min_group_size = nil
      expect(subject).to be_valid
      expect(subject.errors[:min_group_size]).to be_empty
    end
  end

  describe "#staff" do 
    it "returns an alphabetical list of the staff in the course" do 
      course = create(:course)
      staff_1 = create(:user, last_name: 'Zeto')
      staff_2 = create(:user, last_name: 'Able')
      staff_3 = create(:user, last_name: 'Able')
      course_membership = create(:course_membership, user: staff_1, role: "gsi", course: course)
      course_membership = create(:course_membership, user: staff_2, role: "gsi", course: course)
      expect(course.staff).to eq([staff_2,staff_1])
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

  describe "#students_being_graded_by_team(team)"do
    it "returns an alphabetical list of students being graded for a specific team" do
      student = create(:user, last_name: 'Zed')
      student.courses << subject
      student2 = create(:user, last_name: 'Alpha')
      student2.courses << subject
      student3 = create(:user, last_name: 'Mr. Green')
      student3.courses << subject
      team = create(:team, course: subject)
      team.students << [ student, student2] 
      expect(subject.students_being_graded_by_team(team)).to eq([student2,student])
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
      membership = staff_membership
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
end
