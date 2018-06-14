describe CanvasUserImporter do
  describe "#import" do
    it "returns empty results when there are no canvas users" do
      result = described_class.new(nil).import(nil)

      expect(result.successful).to be_empty
      expect(result.unsuccessful).to be_empty
    end

    context "with some canvas users" do
      let(:canvas_user) do
        {
          id: "1234",
          name: "Jimmy Page",
          primary_email: "jimmy@example.com"
        }.stringify_keys
      end
      let(:course) { create :course }
      let(:student) { User.unscoped.last }

      subject { described_class.new([canvas_user]) }

      it "creates the user" do
        expect { subject.import(course) }.to \
          change { User.count }.by 1

        expect(student.email).to eq "jimmy@example.com"
        expect(student.crypted_password).to_not be_blank
        expect(student.first_name).to eq "Jimmy"
        expect(student.last_name).to eq "Page"
      end

      it "sends the activation email to each student" do
        expect { subject.import course }.to \
          change { ActionMailer::Base.deliveries.count }.by 1
      end

      it "creates a link to the user id in canvas" do
        subject.import course

        imported_user = ImportedUser.unscoped.last
        expect(imported_user.user).to eq student
        expect(imported_user.provider).to eq "canvas"
        expect(imported_user.provider_resource_id).to eq "1234"
        expect(imported_user.last_imported_at).to be_within(1.second).of(DateTime.now)
      end

      it "contains a successful row if the user is created" do
        result = subject.import course

        expect(result.successful.count).to eq 1
        expect(result.successful.last).to eq student
      end

      it "contains a successful row if the user's course membership is created" do
        create :user, email: "jimmy@example.com", first_name: "Jimmy",
          last_name: "Page"
        result = subject.import course

        expect(result.successful.count).to eq 1
        expect(result.successful.last).to eq student
      end

      it "does not contain a successful row if the user was not changed and
        their role in the course already exists" do
        create :user, email: "jimmy@example.com", first_name: "Jimmy",
          last_name: "Page", courses: [course], role: :student

        result = subject.import course

        expect(result.successful).to be_empty
      end

      it "contains an unsuccessful row if the user is not valid" do
        canvas_user.merge!("primary_email" => "jimmy@example")

        result = subject.import course

        expect(result.successful.count).to eq 0
        expect(result.unsuccessful.count).to eq 1
        expect(result.unsuccessful.first[:errors]).to eq "Email is invalid"
      end

      context "when there are no enrollments provided" do
        it "creates the course membership with a student role if it does not exist" do
          subject.import(course)

          expect(student.course_memberships.first.course).to eq course
          expect(student.course_memberships.first.role).to eq "student"
        end

        it "does not create a course membership if one already exists" do
          create :user, first_name: "Jimmy", last_name: "Page",
            email: "jimmy@example.com", username: "jimmy", password: "blah",
            courses: [course], role: :student

          result = subject.import course

          expect(student.course_memberships.count).to eq 1
          expect(result.unchanged.count).to eq 1
        end
      end

      context "when there are enrollments provided" do
        let(:enrollments) do
          {
            enrollments: [
              { "type" => "TeacherEnrollment", "enrollment_state" => "active" }
            ]
          }.stringify_keys
        end

        before(:each) { canvas_user.merge!(enrollments) }

        it "creates the course membership with the given role if it does not exist" do
          subject.import(course)

          expect(student.course_memberships.first.course).to eq course
          expect(student.course_memberships.first.role).to eq "professor"
        end

        it "updates the course membership if one exists and the role has changed" do
          user = create :user, first_name: "Jimmy", last_name: "Page",
            email: "jimmy@example.com", username: "jimmy", password: "blah",
            courses: [course], role: :student

          result = subject.import course

          expect(user.course_memberships.count).to eq 1
          expect(user.role(course)).to eq "professor"
          expect(subject.successful.count).to eq 1
        end
      end
    end
  end
end
