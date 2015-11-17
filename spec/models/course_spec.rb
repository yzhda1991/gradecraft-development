require "active_record_spec_helper"

describe Course, focus: true do
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

  describe "#students_auditing" do
    it "returns an alphabetical list of students auditing a course" do
      student = create(:user, last_name: 'Zed')
      student2 = create(:user, last_name: 'Alpha')
      student3 = create(:user)
      course_membership = create(:auditing_membership, user: student, course: subject)
      course_membership = create(:auditing_membership, user: student2, course: subject)
      expect(subject.students_auditing).to eq([student2,student])
    end
  end

  describe "#students_auditing_by_team(team)" do
    it "returns an alphabetical list of students auditing a course on a specific team" do
      student = create(:user, last_name: 'Zed')
      course_membership = create(:auditing_membership, user: student, course: subject)
      student2 = create(:user, last_name: 'Alpha')
      student2.courses << subject
      student3 = create(:user, last_name: 'Mr. Green')
      course_membership_2 = create(:auditing_membership, user: student3, course: subject)
      team = create(:team, course: subject)
      team.students << [ student, student2] 
      expect(subject.students_auditing_by_team(team)).to eq([student])
    end
  end

  describe "#students_by_team(team)" do 
    it "returns an alphabetical list of all students in a team" do
      student = create(:user, last_name: 'Zed')
      course_membership = create(:auditing_membership, user: student, course: subject)
      student2 = create(:user, last_name: 'Alpha')
      student2.courses << subject
      student3 = create(:user, last_name: 'Mr. Green')
      course_membership_2 = create(:auditing_membership, user: student3, course: subject)
      team = create(:team, course: subject)
      team.students << [ student, student2] 
      expect(subject.students_by_team(team)).to eq([student2, student])
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

  describe "#assignment_term" do 
    it "returns the set assignment_term if present" do 
      subject.assignment_term = 'Quest'  
      expect(subject.assignment_term).to eq("Quest")
    end

    it "returns Assignment if no assignment_term is present" do 
      expect(subject.assignment_term).to eq("Assignment")
    end
  end

  describe "#badge_term" do 
    it "returns the set badge_term if present" do 
      subject.badge_term = 'Achievement'  
      expect(subject.badge_term).to eq("Achievement")
    end

    it "returns Badge if no badge_term is present" do 
      expect(subject.badge_term).to eq("Badge")
    end
  end

  describe "#challenge_term" do 
    it "returns the set challenge_term if present" do 
      subject.challenge_term = 'Boss Battle'  
      expect(subject.challenge_term).to eq("Boss Battle")
    end

    it "returns Challenge if no challenge_term is present" do 
      expect(subject.challenge_term).to eq("Challenge")
    end
  end

  describe "#fail_term" do 
    it "returns the set fail_term if present" do 
      subject.fail_term = 'Miss'  
      expect(subject.fail_term).to eq("Miss")
    end

    it "returns Fail if no fail_term is present" do 
      expect(subject.fail_term).to eq("Fail")
    end
  end

  describe "#group_term" do 
    it "returns the set group_term if present" do 
      subject.group_term = 'Flange'  
      expect(subject.group_term).to eq("Flange")
    end

    it "returns Group if no group_term is present" do 
      expect(subject.group_term).to eq("Group")
    end
  end

  describe "#pass_term" do 
    it "returns the set pass_term if present" do  
      subject.pass_term = 'Win'  
      expect(subject.pass_term).to eq("Win")
    end

    it "returns Pass if no pass_term is present" do 
      expect(subject.pass_term).to eq("Pass")
    end
  end

  describe "#team_term" do 
    it "returns the set team_term if present" do 
      subject.team_term = 'Horde'  
      expect(subject.team_term).to eq("Horde")
    end

    it "returns Team if no team_term is present" do 
      expect(subject.team_term).to eq("Team")
    end
  end

  describe "#team_leader_term" do 
    it "returns the set team_leader_term if present" do 
      subject.team_leader_term = 'Captain'  
      expect(subject.team_leader_term).to eq("Captain")
    end

    it "returns Team Leader if no team_leader_term is present" do 
      expect(subject.team_leader_term).to eq("Team Leader")
    end
  end

  describe "#weight_term" do 
    it "returns the set weight_term if present" do 
      subject.weight_term = 'Kapital'  
      expect(subject.weight_term).to eq("Kapital")
    end

    it "returns Weight if no weight_term is present" do 
      expect(subject.weight_term).to eq("Multiplier")
    end
  end

  describe "#user_term" do 
    it "returns the set user_term if present" do 
      subject.user_term = 'User'  
      expect(subject.user_term).to eq("User")
    end

    it "returns User if no user_term is present" do 
      expect(subject.user_term).to eq("Player")
    end
  end

end
