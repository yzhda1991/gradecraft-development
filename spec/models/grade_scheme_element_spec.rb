describe GradeSchemeElement do
  let(:student) { build :user }
  let(:course) { build :course }

  subject { create :grade_scheme_element, lowest_points: 1000, course: course }

  before do
    create :course_membership, :student, user: student, course: course,
      score: 82, earned_grade_scheme_element_id: subject.id
  end

  describe "validations" do
    it "is valid with a course" do
      expect(subject).to be_valid
    end

    it "is invalid without a course" do
      subject.course = nil
      expect(subject).to be_invalid
    end

    it "is invalid if lowest points is not numeric" do
      subject.lowest_points = "one"
      expect(subject).to be_invalid
    end

    it "is invalid if lowest points is greater than a length of nine" do
      subject.lowest_points = 1234567890
      expect(subject).to be_invalid
    end
  end

  describe ".next_highest_element_for" do
    context "when there is a grade scheme element with a higher point threshold" do
      it "returns the next highest element with lowest points" do
        grade_scheme_element = create :grade_scheme_element, lowest_points: 5000,
          course: course
        expect(GradeSchemeElement.next_highest_element_for(subject)).to \
          eq grade_scheme_element
      end
    end

    context "when there is not a grade scheme element with a higher point threshold" do
      it "returns nil" do
        expect(GradeSchemeElement.next_highest_element_for(subject)).to be_nil
      end
    end
  end

  describe ".next_lowest_element_for" do
    context "when there is a grade scheme element with a lower point threshold" do
      it "returns the next lowest element with lowest points" do
        grade_scheme_element = create :grade_scheme_element, lowest_points: 500,
          course: course
        expect(GradeSchemeElement.next_lowest_element_for(subject)).to \
          eq grade_scheme_element
      end
    end

    context "when there is not a grade scheme element with a lower point threshold" do
      it "returns nil" do
        expect(GradeSchemeElement.next_lowest_element_for(subject)).to be_nil
      end
    end
  end

  describe "#copy" do
    let(:grade_scheme_element) { build :grade_scheme_element }
    subject { grade_scheme_element.copy }

    it "makes a duplicated copy of itself" do
      expect(subject).to_not eq grade_scheme_element
    end
  end

  describe ".default" do
    subject { described_class.default }
    it "returns a new grade scheme element" do
      expect(subject).to_not be_persisted
    end

    it "returns a default level" do
      expect(subject.level).to eq "Not yet on board"
    end
  end

  describe "#name" do
    it "returns the name as the level and letter if both are present" do
      subject.level = "Kvothe Kingkiller"
      subject.letter = "B+"
      expect(subject.name).to eq("B+ / Kvothe Kingkiller")
    end

    it "returns the name as just the level if present" do
      subject.level = "Kvothe Kingkiller"
      expect(subject.name).to eq("Kvothe Kingkiller")
    end

    it "returns the name as just the letter if present" do
      subject.letter = "B+"
      expect(subject.name).to eq("B+")
    end

    it "returns nil if no aspects are present" do
      expect(subject.name).to eq(nil)
    end
  end

  describe "#points_to_next_level(student, course)" do
    context "when the current element has the highest point threshold" do
      it "returns 0" do
        allow(subject).to receive(:next_highest_element).and_return nil
        expect(subject.points_to_next_level(student, course)).to eq 0
      end
    end

    context "when the current element does not have the highest point threshold" do
      let(:next_highest_element) { double :element, lowest_points: 100 }
      subject { create :grade_scheme_element, lowest_points: 0, course: course }

      it "returns the difference between the next highest element's point threshold and
      the student's current total score" do
        allow(subject).to receive(:next_highest_element).and_return next_highest_element
        expect(subject.points_to_next_level(student, course)).to eq(18)
      end
    end
  end

  describe "#progress_percent(student)" do
    context "when the current element is has the highest point threshold" do
      it "returns one hundred (100)" do
        allow(subject).to receive(:range).and_return Float::INFINITY
        expect(subject.progress_percent(student)).to eq 100
      end
    end

    context "when the current level does not have the highest point threshold" do
      subject { create :grade_scheme_element, lowest_points: 0, course: course }

      it "returns the percent complete value for the student" do
        allow(subject).to receive(:range).and_return 100
        expect(subject.progress_percent(student)).to eq 82
      end
    end
  end

  describe "#within_range?" do
    subject { create :grade_scheme_element, lowest_points: 1000, course: course }

    it "returns true if the score is between the low and high ranges" do
      expect(subject).to be_within_range 1500
    end

    it "returns true if the score is equal to the low range" do
      expect(subject).to be_within_range 1000
    end

    it "returns true if the score is equal to the high range" do
      expect(subject).to be_within_range 1999
    end

    it "returns false if the score is below the low range" do
      expect(subject).to_not be_within_range 999
    end

    it "returns true when the element has the highest point threshold
      and is greater than the low range" do
      expect(subject).to be_within_range 2000
    end

    it "returns false if the element is not the highest point threshold
      and is greater than the low range" do
      create :grade_scheme_element, lowest_points: 2000, course: course
      expect(subject).to_not be_within_range 2000
    end
  end

  describe "#count_students_earned" do
    it "returns the number of students who have earned this grade scheme element" do
      expect(subject.count_students_earned).to eq(1)
    end
  end

  describe "#next_highest_element" do
    it "returns the next highest level relative to itself" do
      expect(GradeSchemeElement).to receive(:next_highest_element_for).with(subject)
      subject.next_highest_element
    end
  end

  describe "#next_lowest_element" do
    it "returns the next highest element relative to itself" do
      expect(GradeSchemeElement).to receive(:next_lowest_element_for).with(subject)
      subject.next_lowest_element
    end
  end

  describe "#range" do
    context "when the current level has the highest points threshold in the course" do
      it "returns infinity" do
        allow(subject).to receive(:next_highest_element).and_return nil
        expect(subject.range).to eq Float::INFINITY
      end
    end

    context "when the current level does not have the highest points threshold in the course" do
      let(:next_highest_element) { double :element, lowest_points: 1234 }

      it "returns the range for the current level" do
        allow(subject).to receive(:next_highest_element).and_return next_highest_element
        expect(subject.range).to eq 233
      end
    end
  end
end
