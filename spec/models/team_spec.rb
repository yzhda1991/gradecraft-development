require "active_record_spec_helper"

describe Team do
  describe "validations" do
    let(:course) { create :course }

    it "requires that the team name be unique per course" do
      create :team, course_id: course.id, name: "Zeppelin"
      team = Team.new course_id: course.id, name: "zeppelin"
      expect(team).to_not be_valid
      expect(team.errors[:name]).to include "has already been taken"
    end

    it "can have the same name if it's for a different course" do
      create :team, course_id: course.id, name: "Zeppelin"
      team = Team.new course_id: create(:course).id, name: "Zeppelin"
      expect(team).to be_valid
    end
  end

  describe ".find_by_course_and_name" do
    let(:team) { create :team }

    it "returns the team for the specific course id and name" do
      result = Team.find_by_course_and_name team.course_id, team.name.upcase
      expect(result).to eq team
    end
  end

  describe "#member_count" do
    it "returns the number of students on the team" do
      team = create(:team)
      student = create(:user)
      student_2 = create(:user)
      student_3 = create(:user)
      team.students << [student, student_2, student_3]
      expect(team.member_count).to eq(3)
    end
  end

  describe "#badge_count" do
    it "returns the number of earned badges for the team" do
      course = create(:course)
      team = create(:team, course: course)
      student = create(:user)
      student_2 = create(:user)
      student_3 = create(:user)
      badge = create(:badge)
      team.students << [student, student_2, student_3]
      earned_badge = create(:earned_badge, student: student, course: course, student_visible: true)
      earned_badge_1 = create(:earned_badge, student: student, student_visible: true, course: course )
      earned_badge_2 = create(:earned_badge, student: student_2, student_visible: true, course: course )
      earned_badge_3 = create(:earned_badge, student: student_2, student_visible: true, course: course )
      earned_badge_4 = create(:earned_badge, student: student_3, student_visible: true, course: course)
      expect(team.badge_count).to eq(5)
    end
  end

  describe "#total_earned_points" do
    it "returns the total points earned by students for the team" do
      course = create(:course)
      team = create(:team, course: course)
      student = create(:user)
      course_membership = create(:course_membership, user: student, course: course, score: 100)
      student_2 = create(:user)
      course_membership = create(:course_membership, user: student_2, course: course, score: 100)
      student_3 = create(:user)
      course_membership = create(:course_membership, user: student_3, course: course, score: 100)
      team.students << [student, student_2]
      expect(team.total_earned_points).to eq(200)
    end
  end

  describe "#average_points" do
    it "returns 0 if there's no one on the team" do
      team = create(:team)
      expect(team.average_points).to eq(0)
    end

    it "returns the average score if team members are present" do
      course = create(:course)
      team = create(:team, course: course)
      student = create(:user)
      course_membership = create(:course_membership, user: student, course: course, score: 100)
      student_2 = create(:user)
      course_membership = create(:course_membership, user: student_2, course: course, score: 100)
      team.students << [student, student_2]
      expect(team.average_points).to eq(100)
    end
  end

  describe "challenge_grade_score" do
    it "sums all earned challenge grades together" do
      course = create(:course)
      team = create(:team, course: course)
      challenge_grade = create(:challenge_grade, score: 100, team: team, status: "Released")
      challenge_grade_2 = create(:challenge_grade, score: 100, team: team, status: "Released")
      challenge_grade_3 = create(:challenge_grade, score: 100, team: team, status: "Released")
      expect(team.challenge_grade_score).to eq(300)
    end

    it "should not include grades that are not student visible" do
      course = create(:course)
      team = create(:team, course: course)
      challenge_grade = create(:challenge_grade, score: 100, team: team, status: "Released")
      challenge_grade_2 = create(:challenge_grade, score: 100, team: team, status: nil)
      expect(team.challenge_grade_score).to eq(100)
    end
  end

  describe "#update_team_rank" do

    it "Reassigns rank based on challenge grade scores" do
      course = create(:course, team_score_average: false)
      team_1 = create(:team, course: course)
      team_2 = create(:team, course: course)

      challenge = create(:challenge, course: course, release_necessary: true)
      challenge_grade = create(:challenge_grade, challenge: challenge, team: team_1, score: 100, status: "Released")
      challenge_grade_2 = create(:challenge_grade, challenge: challenge, team: team_2, score: 10000, status: "Released")

      team_2.update_ranks
      team_2.reload
      expect(team_2.rank).to eq(1)
    end

  end

  describe "revised_team_score" do
    let(:course) { create :course }
    let(:team) { create(:team, course: course) }

    context "course is using team average for team score" do
      it "returns the average points for the team" do
        allow(course).to receive(:team_score_average) { true }
        allow(team).to receive(:average_points) { 500 }
        expect( team.instance_eval { revised_team_score } ).to eq(500)
      end
    end

    context "course is using challenge grade total for team score" do
      it "returns the challenge grade score for the team" do
        allow(course).to receive(:team_score_average) { false }
        allow(team).to receive(:challenge_grade_score) { 3000 }
        expect( team.instance_eval { revised_team_score } ).to eq(3000)
      end
    end
  end
end
