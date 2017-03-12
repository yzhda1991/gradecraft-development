describe CourseRouter do
  let(:course) { double(:course, id: 456) }

  describe ".change!" do
    let(:user) { double(:user, :current_course_id= => nil, save: true) }

    it "updates the default course id for the user" do
      expect(user).to receive(:current_course_id=).with(456)
      expect(user).to receive(:save)
      described_class.change! user, course
    end

    it "returns the new course" do
      result = described_class.change! user, course
      expect(result).to eq course
    end
  end

  describe ".current_course_for" do
    let(:courses) { double(:active_record_relation) }
    let(:user) { double(:user, courses: courses) }

    it "returns nil if the user is nil" do
      expect(described_class.current_course_for(nil)).to be_nil
    end

    context "with a current course id" do
      it "returns the course that the user has access to" do
        allow(courses).to receive(:where).and_return [course]
        expect(described_class.current_course_for(user, course.id)).to eq course
      end

      it "returns the default course if one is not specified" do
        allow(courses).to receive(:where).and_return [nil]
        allow(user).to receive(:current_course).and_return course
        expect(described_class.current_course_for(user, course.id)).to eq course
      end

      it "returns the first course if there is not one set as the default" do
        allow(courses).to receive(:where).and_return [nil]
        allow(user).to receive(:current_course).and_return nil
        allow(courses).to receive(:first).and_return course
        expect(described_class.current_course_for(user, course.id)).to eq course
      end
    end
  end
end
