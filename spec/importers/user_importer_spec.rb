require 'spec_helper'

describe UserImporter do
  describe "#import" do
    it "returns empty results when there is no file" do
      result = UserImporter.new(nil).import
      expect(result.successful).to be_empty
      expect(result.unsuccessful).to be_empty
    end

    context "with a file" do
      let(:file) { fixture_file "users.csv", "text/csv" }
      let(:course) { create :course }
      let(:team) { Team.unscoped.last }
      let(:user) { User.unscoped.last }
      subject { UserImporter.new(file.tempfile) }
      before { create :team, course: course, name: "Zeppelin" }

      it "creates the student accounts" do
        subject.import course
        expect(user.email).to eq "jimmy@example.com"
        expect(user.crypted_password).to_not be_blank
        expect(user.course_memberships.first.course).to eq course
        expect(user.course_memberships.first.role).to eq "student"
      end

      it "adds the students to the team if the team exists" do
        subject.import course
        expect(team.name).to eq "Zeppelin"
        expect(team.students.first.email).to eq "jimmy@example.com"
      end

      it "creates the team and adds the student if the team does not exist" do
        Team.unscoped.last.destroy
        subject.import course
        expect(team.name).to eq "Zeppelin"
        expect(team.students.first.email).to eq "jimmy@example.com"
      end

      it "sends the activation email to each student" do
        expect { subject.import course }.to \
          change { ActionMailer::Base.deliveries.count }.by 1
      end

      it "contains a successful user if the user and team are valid" do
        result = subject.import course
        expect(result.successful.count).to eq 1
        expect(result.successful.first).to eq user
      end

      it "contains an unsuccessful row if the user is not valid" do
        User.create first_name: "Jimmy", last_name: "Page",
            email: "jimmy@example.com", username: "jimmy"
        result = subject.import course
        expect(result.successful.count).to be_zero
        expect(result.unsuccessful.count).to eq 1
        expect(result.unsuccessful.first[:errors]).to eq "Email has already been taken"
      end

      it "contains an unsuccessful row if the team is not valid" do
        allow_any_instance_of(Team).to receive(:valid?).and_return false
        allow_any_instance_of(Team).to receive(:errors).and_return double(full_messages: ["The team is not cool"])
        result = subject.import course
        expect(result.successful.count).to be_zero
        expect(result.unsuccessful.count).to eq 1
        expect(result.unsuccessful.first[:errors]).to eq "The team is not cool"
      end
    end
  end
end
