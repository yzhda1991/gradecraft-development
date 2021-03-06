describe CourseCreation do
  let(:course) { create :course, has_badges: true, has_teams: true }
  subject { create :course_creation, course: course }

  context "validations" do
    it "is valid with a course" do
      expect(subject).to be_valid
    end

    it "is invalid without course" do
      subject.course = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:course]).to include "can't be blank"
    end
  end

  describe "find or create" do
    it "finds an existing course creation for course" do
      subject
      expect(CourseCreation.find_or_create_for_course(course.id)).to eq(subject)
    end

    it "creates a new course creation if not exists for course" do
      expect{CourseCreation.find_or_create_for_course(course.id)}.to \
        change{ CourseCreation.count }.by(1)
    end
  end

  describe "title for item" do
    it "returns the human readable expanation for each list item" do
      expect(subject.title_for_item("settings_done")).to eq("course settings")
      #expect(subject.title_for_item("attendance_done")).to eq("attendance")
      expect(subject.title_for_item("assignments_done")).to eq("assignments")
      expect(subject.title_for_item("calendar_done")).to eq("calendar events")
      expect(subject.title_for_item("instructors_done")).to eq("set up teaching team")
      expect(subject.title_for_item("roster_done")).to eq("import roster")
      expect(subject.title_for_item("badges_done")).to eq("badges")
      expect(subject.title_for_item("teams_done")).to eq("teams")
    end
  end

  describe "url for item" do
    it "returns the url for each list item" do
      expect(subject.url_for_item("settings_done")).to eq("/courses/#{course.id}/edit")
      #expect(subject.url_for_item("attendance_done")).to eq("...")
      expect(subject.url_for_item("assignments_done")).to eq("/assignments")
      expect(subject.url_for_item("calendar_done")).to eq("/events")
      expect(subject.url_for_item("instructors_done")).to eq("/staff")
      expect(subject.url_for_item("roster_done")).to eq("/users/import")
      expect(subject.url_for_item("badges_done")).to eq("/badges")
      expect(subject.url_for_item("teams_done")).to eq("/teams")
    end
  end

  describe "checklist" do
    it "returns all checklist items on the model" do
      expect(subject.checklist).to eq(
        ["settings_done",
         #"attendance_done",
         "assignments_done",
         "calendar_done",
         "instructors_done",
         "roster_done",
         "badges_done",
         "teams_done"]
      )
    end

    it "does not return badges if the course has no badges" do
      course.update(has_badges: false)
      expect(subject.checklist).not_to include("badges_done")
    end

    it "does not return teams if the course has no teams" do
      course.update(has_teams: false)
      expect(subject.checklist).not_to include("teams_done")
    end
  end
end
