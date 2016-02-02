require "spec_helper"
require "./app/presenters/student_leaderboard_presenter"

describe StudentLeaderboardPresenter do
  let(:course) { double(:course) }
  subject { described_class.new course: course }

  describe "#initialize" do
    it "initializes with a course" do
      expect(described_class.new(course: course).course).to eq course
    end
  end

  describe "#has_teams?" do
    it "returns true if the course has teams" do
      allow(course).to receive(:has_teams?).and_return true
      expect(subject).to be_has_teams
    end
  end

  describe "#team" do
    subject { described_class.new course: course, team_id: 123 }

    it "returns the team based on the team_id parameter" do
      team = double(:team, id: 123)
      teams = double(:relation, find_by: team)
      allow(course).to receive(:teams).and_return teams
      expect(subject.team).to eq team
    end
  end

  describe "#teams" do
    it "returns the teams on the coursesubmission_presenter" do
      team = double(:team)
      allow(course).to receive(:teams).and_return [team]
      expect(subject.teams).to eq [team]
    end
  end

  describe "#title" do
    it "always returns 'Leaderboard'" do
      expect(subject.title).to eq "Leaderboard"
    end
  end
end
