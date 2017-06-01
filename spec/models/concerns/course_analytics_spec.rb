describe CourseAnalytics do
  let(:course) { create :course }
  let!(:cm_1) { create :course_membership, :student, course: course, score: 1000 }
  let!(:cm_2) { create :course_membership, :student, course: course, score: 3000 }
  let!(:cm_3) { create :course_membership, :student, course: course, score: 0, auditing: true }

  before(:all) do
  end

  describe "#scores" do
    it "returns and array of scores for non-auditing students" do
      expect(course.scores).to eq([1000,3000])
    end
  end

  describe "#average_score" do
    it "returns the average score for course" do
      expect(course.average_score).to eq(2000)
    end
  end

  describe "#high_score" do
    it "returns the maximum raw score for a graded grade" do
      expect(course.high_score).to eq 3000
    end
  end

  describe "#low_score" do
    it "returns the minimum raw score for a graded grade" do
      expect(course.low_score).to eq 1000
    end
  end
end
