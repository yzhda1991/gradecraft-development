describe CSVStudentImporter do
  let(:course) { create :course }
  before(:all) { User.destroy_all }

  describe "#import" do
    it "returns empty results when there is no file" do
      result = described_class.new(nil, course).import
      expect(result.successful).to be_empty
      expect(result.unsuccessful).to be_empty
    end

    context "with a file" do
      let(:team) { Team.unscoped.last }
      let(:user) { User.unscoped.last }
      before { create :team, course: course, name: "Zeppelin" }

      context "with GradeCraft students" do
        let(:file) { fixture_file "users.csv", "text/csv" }
        subject { described_class.new(file.tempfile, course) }

        it "creates the student accounts" do
          subject.import
          expect(user.email).to eq "csv_jimmy@example.com"
          expect(user.crypted_password).to_not be_blank
          expect(user.course_memberships.first.course).to eq course
          expect(user.course_memberships.first.role).to eq "student"
        end

        it "strips whitespace and creates a valid user" do
          subject.import
          user_2 = User.unscoped.first
          expect(user_2.first_name).to eq "leading"
          expect(user_2.last_name).to eq "trailing"
          expect(user_2.email).to eq "whitespace@example.com"
        end

        it "does not create the student membership if it already exists" do
          create :user, first_name: "Jimmy", last_name: "Page", email: "csv_jimmy@example.com",
            username: "csv_jimmy", password: "blah", courses: [course], role: :student
          expect { subject.import }.to change { CourseMembership.count }.by(2)
        end

        it "adds the students to the team if the team exists" do
          subject.import
          expect(team.name).to eq "Zeppelin"
          expect(team.students.first.email).to eq "csv_jimmy@example.com"
        end

        it "handles empty fields with whitespace" do
          subject.import
          expect(User.unscoped.first.team).to be_nil
        end

        it "just adds the student to the team if the student already exists" do
          User.create first_name: "Jimmy", last_name: "Page",
              email: "csv_jimmy@example.com", username: "jimmy", password: "blah"
          subject.import
          expect(team.students.first.email).to eq "csv_jimmy@example.com"
        end

        it "appends unsuccessful if a course membership already exists for user and there is no change to team" do
          subject.import
          result = subject.import
          expect(result.unsuccessful).to include({data: "Jimmy,Page,csv_jimmy,csv_jimmy@example.com,Zeppelin\n",
            errors: "Unable to import this user, they have already been added to the course"})
        end

        it "creates the team and adds the student if the team does not exist" do
          Team.unscoped.last.destroy
          subject.import
          expect(team.name).to eq "Zeppelin"
          expect(team.students.first.email).to eq "csv_jimmy@example.com"
        end

        it "does not add the student to the team if a team is not specified" do
          subject.import
          user = User.unscoped.first
          expect(team.students).to_not include user
        end

        it "sends the activation email to each student" do
          expect { subject.import }.to \
            change { ActionMailer::Base.deliveries.count }.by 3
        end

        it "contains a successful user if the user and team are valid" do
          result = subject.import
          expect(result.successful.count).to eq 3
          expect(result.successful.last).to eq user
        end

        it "contains unsuccessful rows if the user cannot be created or updated" do
          allow(Services::CreatesOrUpdatesUser).to receive(:call).and_return \
            double(:result, success?: false, message: "")
          result = subject.import
          expect(result.unsuccessful.count).to eq 3
          expect(result.unsuccessful.pluck(:errors)).to include "Unable to create or update user"
        end

        it "contains an unsuccessful row if the team is not valid" do
          allow_any_instance_of(Team).to receive(:valid?).and_return false
          allow_any_instance_of(Team).to receive(:errors).and_return double(full_messages: ["The team is not cool"])
          result = subject.import
          expect(result.successful.count).to eq 2
          expect(result.unsuccessful.count).to eq 1
          expect(result.unsuccessful.first[:errors]).to eq "The team is not cool"
        end
      end

      context "with UM students" do
        let(:file) { fixture_file "internal_users.csv", "text/csv" }
        subject { described_class.new(file.tempfile, course, true) }

        it "creates the student accounts with emails specified" do
          subject.import
          expect(user.email).to eq "richard@umich.edu"
          expect(user.username).to eq "richard"
          expect(user.kerberos_uid).to eq "richard"
          expect(user.course_memberships.first.course).to eq course
          expect(user.course_memberships.first.role).to eq "student"
        end

        it "creates the student accounts with unique names specified" do
          subject.import
          user =  User.unscoped.first
          expect(user.email).to eq "peter@umich.edu"
          expect(user.username).to eq "peter"
          expect(user.kerberos_uid).to eq "peter"
          expect(user.course_memberships.first.course).to eq course
          expect(user.course_memberships.first.role).to eq "student"
        end

        it "does not store a password for the student" do
          subject.import
          expect(user.crypted_password).to be_blank
        end

        it "activates the users" do
          subject.import
          expect(User.all.all?(&:activated?)).to eq true
        end

        it "does not send the activation email to each student" do
          expect { subject.import }.to_not \
            change { ActionMailer::Base.deliveries.count }
        end

        it "can send a welcome email to each student" do
          subject = described_class.new(file.tempfile, course, true, true)
          expect { subject.import }.to \
            change { ActionMailer::Base.deliveries.count }.by 2
        end
      end
    end
  end
end
