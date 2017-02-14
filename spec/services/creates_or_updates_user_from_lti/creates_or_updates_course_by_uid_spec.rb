require "light-service"
require "./app/services/creates_or_updates_user_from_lti/creates_or_updates_course_by_uid"

describe Services::Actions::CreatesOrUpdatesCourseByUID do
  let(:course_attributes) do
    {
      lti_uid: "cosc111",
      course_number: "111",
      name: "Intro to Computery Things"
    }
  end

  it "expects course attributes" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "promises the course" do
    result = described_class.execute course_attributes: course_attributes
    expect(result).to have_key :course
  end

  context "when the course does not exist" do
    it "creates a course" do
      expect{ described_class.execute course_attributes: course_attributes }.to change(Course, :count).by(1)
    end

    it "sets the course attributes" do
      described_class.execute course_attributes: course_attributes
      course = Course.unscoped.last
      expect(course).to have_attributes course_attributes
    end
  end

  context "when the course exists" do
    let!(:course) { create :course, lti_uid: "cosc111" }

    it "does not create a new course" do
      expect{ described_class.execute course_attributes: course_attributes }.to_not change(Course, :count)
    end

    it "updates the course attributes" do
      described_class.execute course_attributes: course_attributes
      expect(course.reload).to have_attributes course_attributes
    end
  end
end
