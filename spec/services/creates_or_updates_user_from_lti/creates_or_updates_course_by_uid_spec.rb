describe Services::Actions::CreatesOrUpdatesCourseByUID do
  let(:course_attributes) do
    {
      lti_uid: "cosc111",
      course_number: "111",
      name: "Intro to Computery Things"
    }
  end

  it "expects course attributes" do
    expect { described_class.execute update_existing: true }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects a value for update existing" do
    expect { described_class.execute course_attributes: course_attributes }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  context "when an existing course should be updated" do
    let(:params) { { course_attributes: course_attributes, update_existing: true } }

    it "creates the course if one is not found" do
      expect{ described_class.execute params }.to change(Course, :count).by(1)
    end

    it "updates the course if it is found" do
      course = create :course, lti_uid: "cosc111"
      described_class.execute params
      expect(course.reload).to have_attributes course_attributes
    end

    it "promises the course" do
      result = described_class.execute params
      expect(result).to have_key :course
    end
  end

  context "when an existing course should not be updated" do
    let(:params) { { course_attributes: course_attributes, update_existing: false } }

    it "creates the course if one is not found" do
      expect{ described_class.execute params }.to change(Course, :count).by(1)
    end

    it "does not update the course if it is found" do
      course = create :course, lti_uid: "cosc111"
      described_class.execute params
      expect(course.reload).to_not have_attributes course_attributes.except(:lti_uid)
    end

    it "promises the course" do
      result = described_class.execute params
      expect(result).to have_key :course
    end
  end
end
