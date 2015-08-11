require 'spec_helper'

describe UserImporter do
  describe "#import" do
    it "returns empty results if the file is nil" do
      result = UserImporter.new(nil).import
      expect(result.successful).to be_empty
      expect(result.unsuccessful).to be_empty
    end

    context "with a file" do
      let(:file) { fixture_file "users.csv", "text/csv" }
      let(:course) { create :course }
      subject { UserImporter.new(file.tempfile) }
      before { create :team, course: course, name: "Zeppelin" }

      it "creates the student accounts" do
        subject.import course
        user = User.unscoped.last
        expect(user.email).to eq "jimmy@example.com"
        expect(user.crypted_password).to_not be_blank
        expect(user.course_memberships.first.course).to eq course
        expect(user.course_memberships.first.role).to eq "student"
      end

      it "adds the students to the team if the team exists" do
        subject.import course
        team = Team.unscoped.last
        expect(team.name).to eq "Zeppelin"
        expect(team.students.first.email).to eq "jimmy@example.com"
      end

      it "creates the team and adds the student if the team does not exist" do
        Team.unscoped.last.destroy
        subject.import course
        team = Team.unscoped.last
        expect(team.name).to eq "Zeppelin"
        expect(team.students.first.email).to eq "jimmy@example.com"
      end

      xit "sends the activation email to each student"
    end
  end
end
