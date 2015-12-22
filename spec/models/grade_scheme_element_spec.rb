require "active_record_spec_helper"

describe GradeSchemeElement do

  subject { build(:grade_scheme_element) }

  context "validations" do
    it "is valid with a low range, a high range, and a course" do
      expect(subject).to be_valid
    end

    it "is invalid without a low range" do
      subject.low_range = nil
      expect(subject).to be_invalid
    end

    it "is invalid without a high range" do
      subject.high_range = nil
      expect(subject).to be_invalid
    end

    it "is invalid without a course" do
      subject.course = nil
      expect(subject).to be_invalid
    end
  end

  describe "#copy" do
    let(:grade_scheme_element) { build :grade_scheme_element }
    subject { grade_scheme_element.copy }

    it "makes a duplicated copy of itself" do
      expect(subject).to_not eq grade_scheme_element
    end
  end

  describe "#name" do
    it 'returns the name as the level and letter if both are present' do
      subject.level = "Kvothe Kingkiller"
      subject.letter = "B+"
      expect(subject.name).to eq("B+ / Kvothe Kingkiller")
    end

    it 'returns the name as just the level if present' do
      subject.level = "Kvothe Kingkiller"
      expect(subject.name).to eq("Kvothe Kingkiller")
    end

    it 'returns the name as just the letter if present' do
      subject.letter = "B+"
      expect(subject.name).to eq("B+")
    end

    it "returns nil if no aspects are present" do
      expect(subject.name).to eq(nil)
    end
  end

  describe "#range" do
    it "returns the difference between the high range and the low range" do
      subject.high_range = 100
      subject.low_range = 0
      expect(subject.range).to eq(100)
    end
  end

  describe "#points_to_next_level(student, course)" do
    let(:student) { create :user }
    let(:course) { create :course}

    before do
      create(:course_membership, user: student, course: course, score: 82 )
    end

    it "returns the difference between the current level high range and the student's
    total score + 1 point - the value to achieve the next level" do
      subject.high_range = 100
      subject.course = course
      expect(subject.points_to_next_level(student, course)).to eq(19)
    end
  end

  describe "#progress_percent(student)" do
    let(:student) { create :user }
    let(:course) { create :course}

    before do
      create(:course_membership, user: student, course: course, score: 82 )
    end

    it "returns the level's percent complete value for the student" do
      subject.high_range = 100
      subject.low_range = 0
      subject.course = course
      expect(subject.progress_percent(student)).to eq(82)
    end
  end

end
