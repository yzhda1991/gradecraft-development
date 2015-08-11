require 'spec_helper'

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
end
