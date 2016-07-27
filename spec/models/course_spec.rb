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
      subject.course_number = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:course_number]).to include "can't be blank"
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

  describe "#copy" do
    let(:course) { create :course }
    subject { course.copy nil }

    it "makes a duplicated copy of itself" do
      expect(subject).to_not eq course
    end

    it "prepends the name with 'Copy of'" do
      course.name = "Important Course"
      expect(subject.name).to eq "Copy of Important Course"
    end

    it "saves the copy if the course is saved" do
      expect(subject).to_not be_new_record
    end

    it "copies the badges" do
      create :badge, course: course
      expect(subject.badges.size).to eq 1
      expect(subject.badges.map(&:course_id)).to eq [subject.id]
    end

    it "copies the assignment types" do
      assignment_type = create :assignment_type, course: course
      create :assignment, assignment_type: assignment_type
      expect(subject.assignment_types.size).to eq 1
      expect(subject.assignment_types.map(&:course_id)).to eq [subject.id]
      expect(subject.assignments.map(&:course_id)).to eq [subject.id]
    end

    it "copies the challenges" do
      create :challenge, course: course
      expect(subject.challenges.size).to eq 1
      expect(subject.challenges.map(&:course_id)).to eq [subject.id]
    end

    it "copies the grade scheme elements" do
      create :grade_scheme_element, course: course
      expect(subject.grade_scheme_elements.size).to eq 1
      expect(subject.grade_scheme_elements.map(&:course_id)).to eq [subject.id]
    end
  end

  describe "#copy with students" do
    let!(:student) { create(:student_course_membership, course: subject).user }
    subject { create :course }

    it "turns off the create_admin_memberships callback" do
      expect_any_instance_of(Course).to_not receive(:create_admin_memberships)
      subject.copy "with_students"
    end

    it "turns back on the create_admin_memberships callback" do
      subject.copy "with_students"
      expect(Course._create_callbacks.map(&:filter)).to include :create_admin_memberships
    end

    it "copies the students" do
      duplicated = subject.copy "with_students"
      expect(duplicated.reload.users).to include student
    end
  end

  describe "#grade_scheme_elements" do
    let!(:high) { create(:grade_scheme_element, lowest_points: 2001, highest_points: 3000, course: subject) }
    let!(:low) { create(:grade_scheme_element, lowest_points: 100, highest_points: 1000, course: subject) }
    let!(:middle) { create(:grade_scheme_element, lowest_points: 1001, highest_points: 2000, course: subject) }

    describe "#for_score" do
      it "returns the grade scheme element that falls within that points range" do
        result = subject.grade_scheme_elements.for_score(1100)

        expect(result).to eq middle
      end

      it "returns the highest grade scheme if the score if greater than the highest" do
        result = subject.grade_scheme_elements.for_score(3001)

        expect(result).to eq high
      end

      it "returns a new grade scheme if the score is lower that the lowest" do
        result = subject.grade_scheme_elements.for_score(99)

        expect(result.level).to eq "Not yet on board"
      end

      it "handles no grade scheme elements" do
        subject.grade_scheme_elements.delete_all

        result = subject.grade_scheme_elements.for_score(99)

        expect(result).to be_nil
      end

      it "does not include other courses" do
        another_course = create :course
        create :grade_scheme_element, lowest_points: 0, highest_points: 100, course: another_course

        result = subject.grade_scheme_elements.for_score(99)

        expect(result.id).to be_nil
      end
    end
  end

  describe "#staff" do
    it "returns an alphabetical list of the staff in the course" do
      course = create(:course)
      staff_1 = create(:user, last_name: "Zeto")
      staff_2 = create(:user, last_name: "Able")
      staff_3 = create(:user, last_name: "Able")
      course_membership = create(:course_membership, user: staff_1, role: "gsi", course: course)
      course_membership = create(:course_membership, user: staff_2, role: "gsi", course: course)
      expect(course.staff).to eq([staff_2,staff_1])
    end
  end

  describe "#students_being_graded" do
    it "returns an alphabetical list of students being graded" do
      student = create(:user, last_name: "Zed")
      student.courses << subject
      student2 = create(:user, last_name: "Alpha")
      student2.courses << subject
      expect(subject.students_being_graded).to eq([student2,student])
    end
  end

  describe "#students_being_graded_by_team(team)" do
    it "returns an alphabetical list of students being graded for a specific team" do
      student = create(:user, last_name: "Zed")
      student.courses << subject
      student2 = create(:user, last_name: "Alpha")
      student2.courses << subject
      student3 = create(:user, last_name: "Mr. Green")
      student3.courses << subject
      team = create(:team, course: subject)
      team.students << [ student, student2]
      expect(subject.students_being_graded_by_team(team)).to eq([student2,student])
    end
  end

  describe "#students_by_team(team)" do
    it "returns an alphabetical list of all students in a team" do
      student = create(:user, last_name: "Zed")
      course_membership = create(:auditing_membership, user: student, course: subject)
      student2 = create(:user, last_name: "Alpha")
      student2.courses << subject
      student3 = create(:user, last_name: "Mr. Green")
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
      subject.assignment_term = "Quest"
      expect(subject.assignment_term).to eq("Quest")
    end

    it "returns Assignment if no assignment_term is present" do
      expect(subject.assignment_term).to eq("Assignment")
    end
  end

  describe "#badge_term" do
    it "returns the set badge_term if present" do
      subject.badge_term = "Achievement"
      expect(subject.badge_term).to eq("Achievement")
    end

    it "returns Badge if no badge_term is present" do
      expect(subject.badge_term).to eq("Badge")
    end
  end

  describe "#challenge_term" do
    it "returns the set challenge_term if present" do
      subject.challenge_term = "Boss Battle"
      expect(subject.challenge_term).to eq("Boss Battle")
    end

    it "returns Challenge if no challenge_term is present" do
      expect(subject.challenge_term).to eq("Challenge")
    end
  end

  describe "#fail_term" do
    it "returns the set fail_term if present" do
      subject.fail_term = "Miss"
      expect(subject.fail_term).to eq("Miss")
    end

    it "returns Fail if no fail_term is present" do
      expect(subject.fail_term).to eq("Fail")
    end
  end

  describe "#group_term" do
    it "returns the set group_term if present" do
      subject.group_term = "Flange"
      expect(subject.group_term).to eq("Flange")
    end

    it "returns Group if no group_term is present" do
      expect(subject.group_term).to eq("Group")
    end
  end

  describe "#pass_term" do
    it "returns the set pass_term if present" do
      subject.pass_term = "Win"
      expect(subject.pass_term).to eq("Win")
    end

    it "returns Pass if no pass_term is present" do
      expect(subject.pass_term).to eq("Pass")
    end
  end

  describe "#team_term" do
    it "returns the set team_term if present" do
      subject.team_term = "Horde"
      expect(subject.team_term).to eq("Horde")
    end

    it "returns Team if no team_term is present" do
      expect(subject.team_term).to eq("Team")
    end
  end

  describe "#team_leader_term" do
    it "returns the set team_leader_term if present" do
      subject.team_leader_term = "Captain"
      expect(subject.team_leader_term).to eq("Captain")
    end

    it "returns Team Leader if no team_leader_term is present" do
      expect(subject.team_leader_term).to eq("Team Leader")
    end
  end

  describe "#weight_term" do
    it "returns the set weight_term if present" do
      subject.weight_term = "Kapital"
      expect(subject.weight_term).to eq("Kapital")
    end

    it "returns Weight if no weight_term is present" do
      expect(subject.weight_term).to eq("Multiplier")
    end
  end

  describe "#student_term" do
    it "returns the set student_term if present" do
      subject.student_term = "User"
      expect(subject.student_term).to eq("User")
    end

    it "returns User if no student_term is present" do
      expect(subject.student_term).to eq("Player")
    end
  end

  describe "#has_teams?" do
    it "does not have teams by default" do
      expect(subject.has_teams?).to eq(false)
    end

    it "has teams if they're turned on" do
      subject.has_teams = true
      expect(subject.has_teams?).to eq(true)
    end
  end

  describe "#has_team_challenges?" do
    it "does not have team challenges by default" do
      expect(subject.has_team_challenges?).to eq(false)
    end

    it "has team challenges if they're turned on" do
      subject.has_team_challenges = true
      expect(subject.has_team_challenges?).to eq(true)
    end
  end

  describe "#teams_visible?" do
    it "does not have team visible by default" do
      expect(subject.teams_visible?).to eq(false)
    end

    it "has team visible if it's turned on" do
      subject.teams_visible = true
      expect(subject.teams_visible?).to eq(true)
    end
  end

  describe "#has_in_team_leaderboard?" do
    it "does not have in-team leaderboards turned on by default" do
      expect(subject.has_in_team_leaderboard?).to eq(false)
    end

    it "has in-team leaderboards if they're turned on" do
      subject.has_in_team_leaderboard = true
      expect(subject.has_in_team_leaderboard?).to eq(true)
    end
  end

  describe "#active?" do
    it "returns true if the course status equals true" do
      subject.status = true
      expect(subject.active?).to eq(true)
    end

    it "returns false if the course status equals false" do
      subject.status = false
      expect(subject.active?).to eq(false)
    end
  end

  describe "#has_badges?" do
    it "does not have badges turned on by default" do
      expect(subject.has_badges?).to eq(false)
    end

    it "has badges if they're turned on" do
      subject.has_badges = true
      expect(subject.has_badges?).to eq(true)
    end
  end

  describe "#valuable_badges?" do
    it "does not have badge with points by default" do
      expect(subject.valuable_badges?).to eq(false)
    end

    it "registers as having valuable has badges with points if they exist" do
      badge = create(:badge, full_points: 1000, course: subject)
      expect(subject.valuable_badges?).to eq(true)
    end
  end

  describe "#has_groups?" do
    it "does not have badges turned on by default" do
      expect(subject.has_groups?).to eq(false)
    end

    it "has badges if they're turned on" do
      subject.group_setting = true
      expect(subject.has_groups?).to eq(true)
    end

  end

  describe "#min_group_size" do
    it "sets the default min group size at 2" do
      expect(subject.min_group_size).to eq(2)
    end

    it "accepts the instructor's setting here if it exists" do
      subject.min_group_size = 3
      expect(subject.min_group_size).to eq(3)
    end
  end

  describe "#max_group_size" do
    it "sets the default max group size at 6" do
      expect(subject.max_group_size).to eq(6)
    end

    it "accepts the instructor's setting here if it exists" do
      subject.max_group_size = 8
      expect(subject.max_group_size).to eq(8)
    end
  end

  describe "#formatted_tagline" do
    it "returns an empty string if no tagline is present" do
      expect(subject.formatted_tagline).to eq(" ")
    end

    it "returns a tagline if present" do
      subject.tagline = "Good night, Westley. Good work. Sleep well. I'll most likely kill you in the morning."
      expect(subject.formatted_tagline).to eq("Good night, Westley. Good work. Sleep well. I'll most likely kill you in the morning.")
    end
  end

  describe "#formatted_short_name" do
    it "uses the course number if that's all that's present" do
      expect(subject.formatted_short_name).to eq(subject.course_number)
    end

    it "creates a formatted short name that includes the course number, semester, and year if they're present" do
      subject.semester = "Fall"
      subject.year = "2015"

      expect(subject.formatted_short_name).to eq("#{subject.course_number} #{(subject.semester).capitalize.first[0]}#{subject.year}")
    end

  end

  describe "#time_zone" do
    subject { course.time_zone }
    let(:course) { create(:course) }

    it "defaults to Eastern Time" do
      expect(subject).to eq("Eastern Time (US & Canada)")
    end
  end

  describe "#total_points" do
    it "returns the total points available if they're set by the instructor" do
      subject.full_points = 100000
      expect(subject.total_points).to eq(subject.full_points)
    end

    it "sums up the available points in the assignments if there's no point total set" do
      course = create(:course)
      course.full_points = nil
      assignment = create(:assignment, course_id: course.id, full_points: 101)
      assignment_2 = create(:assignment, course_id: course.id, full_points: 1000)
      expect(course.total_points).to eq(1101)
    end
  end

  describe "#student_weighted?" do
    it "returns false if no weights are set" do
      subject.total_weights = nil
      expect(subject.student_weighted?).to eq(false)
    end

    it "returns true if weights have been set by the instructor" do
      subject.total_weights = 5
      expect(subject.student_weighted?).to eq(true)
    end
  end

  describe "#assignment_weight_open?" do
    it "returns false if the weights_close_at date is past" do
      subject.weights_close_at = Date.today - 1
      expect(subject.assignment_weight_open?).to eq(false)
    end

    it "returns true if there is no close at date" do
      expect(subject.assignment_weight_open?).to eq(true)
    end

    it "returns true if the close date is in the future" do
      subject.weights_close_at = Date.today + 1
      expect(subject.assignment_weight_open?).to eq(true)
    end
  end

  describe "#has_team_roles?" do
    it "turns team roles for students in their profile settings to true if the instructor turns them on" do
      subject.has_team_roles = true
      expect(subject.has_team_roles?).to eq(true)
    end
    it "returns false for team roles if the instructor has not turned them on" do
      subject.has_team_roles = false
      expect(subject.has_team_roles?).to eq(false)
    end
  end

  describe "#has_submissions?" do
    it "returns true if the instructor has turned submissions on" do
      subject.accepts_submissions = true
      expect(subject.has_submissions?).to eq(true)
    end
    it "returns false for submissions if the instructor has not turned them on" do
      subject.accepts_submissions = false
      expect(subject.has_submissions?).to eq(false)
    end
  end

  describe "#grade_level_for_score(score)" do
    it "returns the grade level that matches the score" do
      low_grade_scheme_element = create(:grade_scheme_element_low, course: subject)
      high_grade_scheme_element = create(:grade_scheme_element_high, course: subject)
      expect(subject.grade_level_for_score(9990)).to eq("Awful")
    end
  end

  describe "#grade_letter_for_score(score)" do
    it "returns the grade letter that matches the score" do
      low_grade_scheme_element = create(:grade_scheme_element_low, course: subject)
      high_grade_scheme_element = create(:grade_scheme_element_high, course: subject)
      expect(subject.grade_letter_for_score(9990)).to eq("F")
    end
  end

  describe "#element_for_score(score)" do
    it "returns the level that matches the score" do
      low_grade_scheme_element = create(:grade_scheme_element_low, course: subject)
      high_grade_scheme_element = create(:grade_scheme_element_high, course: subject)
      expect(subject.element_for_score(10000)).to eq(high_grade_scheme_element)
    end
  end

  describe "#membership_for_student(student)" do
    it "returns the membership relationship for a student" do
      student = create(:user)
      course_membership = create(:course_membership, user: student, course: subject)
      expect(subject.membership_for_student(student)).to eq(course_membership)
    end
  end

  describe "#assignment_weight_for_student(student)" do
    it "sums the assignment weights the student has spent" do
      student = create(:user)
      student.courses << subject
      assignment_weight_1 = create(:assignment_type_weight, student: student, course: subject, weight: 2)
      assignment_weight_2 = create(:assignment_type_weight, student: student, course: subject, weight: 2)
      expect(subject.assignment_weight_for_student(student)).to eq(4)
    end
  end

  describe "#assignment_weight_spent_for_student(student)" do
    it "returns false if the student has not yet spent enough weights" do
      subject.total_weights = 4
      student = create(:user)
      student.courses << subject
      assignment_weight_1 = create(:assignment_type_weight, student: student, course: subject, weight: 2)
      expect(subject.assignment_weight_spent_for_student(student)).to eq(false)
    end

    it "returns true if the student has spent enough weights" do
      subject.total_weights = 4
      student = create(:user)
      student.courses << subject
      assignment_weight_1 = create(:assignment_type_weight, student: student, course: subject, weight: 2)
      assignment_weight_2 = create(:assignment_type_weight, student: student, course: subject, weight: 2)
      expect(subject.assignment_weight_spent_for_student(student)).to eq(true)
    end
  end

  describe "#score_for_student(student)" do
    it "returns a student's score for a specific course" do
      student = create(:user)
      course_membership = create(:student_course_membership, score: 101, user: student, course: subject)
      expect(subject.score_for_student(student)).to eq(101)
    end
  end

  describe "#minimum_course_score" do
    it "returns the lowest student score in the course" do
      student = create(:user)
      course_membership = create(:student_course_membership, course: subject, user: student, score: 100)
      student_2 = create(:user)
      course_membership = create(:student_course_membership, course: subject, user: student_2, score: 2000)
      student_3 = create(:user)
      course_membership = create(:student_course_membership, course: subject, user: student_3, score: 2990)
      expect(subject.minimum_course_score).to eq(100)
    end
  end

  describe "#maximum_course_score" do
    it "returns the highest student score in the course" do
      student = create(:user)
      course_membership = create(:student_course_membership, course: subject, user: student, score: 100)
      student_2 = create(:user)
      course_membership = create(:student_course_membership, course: subject, user: student_2, score: 2000)
      student_3 = create(:user)
      course_membership = create(:student_course_membership, course: subject, user: student_3, score: 2990)
      expect(subject.maximum_course_score).to eq(2990)
    end
  end

  describe "#average_course_score" do
    it "returns the average student score in the course" do
      student = create(:user)
      course_membership = create(:student_course_membership, course: subject, user: student, score: 100)
      student_2 = create(:user)
      course_membership = create(:student_course_membership, course: subject, user: student_2, score: 2000)
      student_3 = create(:user)
      course_membership = create(:student_course_membership, course: subject, user: student_3, score: 2990)
      expect(subject.average_course_score).to eq(1696)
    end
  end

  describe "#student_count" do
    it "counts the number of students in a course" do
      student = create(:user)
      student.courses << subject
      student2 = create(:user)
      student2.courses << subject
      student3 = create(:user)
      student3.courses << subject
      student4 = create(:user)
      expect(subject.student_count).to eq(3)
    end
  end

  describe "#graded_student_count" do
    it "returns the number of student who are being graded in the course" do
      student = create(:user, last_name: "Zed")
      student2 = create(:user, last_name: "Alpha")
      student3 = create(:user)
      student3.courses << subject
      course_membership = create(:auditing_membership, user: student, course: subject)
      course_membership = create(:auditing_membership, user: student2, course: subject)
      expect(subject.graded_student_count).to eq(1)
    end
  end

  describe "#point_total_for_challenges" do
    it "sums up the total number of points in the challenges" do
      challenge = create(:challenge, course: subject, full_points: 101)
      challenge_2 = create(:challenge, course: subject, full_points: 1000)
      expect(subject.point_total_for_challenges).to eq(1101)
    end
  end

  describe "#ordered_student_ids" do
    it "returns an ordered array of student ids" do
      student_2 = create(:user)
      student_2.courses << subject
      student_1 = create(:user)
      student_1.courses << subject
      student_3 = create(:user)
      student_3.courses << subject
      expect(subject.ordered_student_ids).to eq([student_2.id, student_1.id, student_3.id])
    end
  end

  describe "#course_badge_count" do
    it "tallies the number of badges in a course" do
      badge = create(:badge, course: subject)
      badge1 = create(:badge, course: subject)
      badge2 = create(:badge, course: subject)
      badge3 = create(:badge, course: subject)
      expect(subject.course_badge_count).to eq(4)
    end
  end

  describe "#awarded_course_badge_count" do
    it "tallies the number of earned badges in a course" do
      badge = create(:badge, course: subject)
      student = create(:user)
      earned_badge = create(:earned_badge, badge: badge, student: student, course: subject, student_visible: true)
      earned_badge_2 = create(:earned_badge, badge: badge, student: student, course: subject, student_visible: true)
      earned_badge_3 = create(:earned_badge, badge: badge, student: student, course: subject, student_visible: true)
      expect(subject.awarded_course_badge_count).to eq(3)
    end
  end

  describe "#max_more_than_min" do
    it "errors out if the max group size is smaller than the minimum" do
      subject.max_group_size = 2
      subject.min_group_size = 5
      expect !subject.valid?
    end
  end

  describe "#create_admin_memberships" do
    it "creates admin memberships for all courses automatically on creation of new courses" do
      admin = create(:user, admin: true)
      course = create(:course)
      new_course = create(:course)
      expect(admin.course_memberships.count).to eq(2)
    end
  end

end
