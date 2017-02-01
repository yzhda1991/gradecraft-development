require "active_record_spec_helper"

describe TeamMembership do

  subject { build(:team_membership) }

  context "validations" do
    it "is valid with a team, and a student" do
      expect(subject).to be_valid
    end
  end

  describe "#copy" do
    let(:team_membership) { build :team_membership }
    subject { team_membership.copy }

    it "makes a duplicated copy of itself" do
      expect(subject).to_not eq team_membership
    end
  end

  describe ".for_course" do
    it "returns all the team memberships for a specific course" do
      course = create(:course)
      course_team_membership = create(:team_membership,
                                      team: create(:team, course: course))
      another_team_membership = create(:team_membership)
      results = TeamMembership.for_course(course)
      expect(results).to_not include [another_team_membership]
    end
  end

  describe ".for_student" do
    it "returns all the team memberships for a specific student" do
      student = create(:user)
      student_team_membership = create(:team_membership, student: student)
      another_team_membership = create(:team_membership)
      results = TeamMembership.for_student(student)
      expect(results).to eq [student_team_membership]
    end
  end

end
