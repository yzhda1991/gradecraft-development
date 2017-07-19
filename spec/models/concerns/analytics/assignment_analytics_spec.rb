
describe Analytics::AssignmentAnalytics do
  subject { build(:assignment, course: course) }
  let(:course) { create(:course) }
  let(:student1) { create(:course_membership, :student, course: course, active: true).user }
  let(:student2) { create(:course_membership, :student, course: course, active: true).user }
  let(:student3) { create(:course_membership, :student, course: course, active: true).user }
  let(:student_deactive) { create(:course_membership, :student, course: course, active: false).user }

  describe "#average" do
    before { subject.save }

    it "returns the average raw score for a graded grade" do
      subject.grades.create student_id: student1.id, raw_points: 8, student_visible: true
      subject.grades.create student_id: student2.id, raw_points: 5, student_visible: true
      subject.grades.create student_id: student_deactive.id, raw_points: 10, status: "Graded"
      expect(subject.average).to eq 6
    end

    it "returns nil if there are no grades" do
      expect(subject.average).to be_nil
    end
  end

  describe "#earned_average" do
    before { subject.save }

    it "returns the average score for a graded grade" do
      subject.grades.create student_id: student1.id, raw_points: 8, score: 8, student_visible: true
      subject.grades.create student_id: student2.id, raw_points: 5, score: 8, student_visible: true
      subject.grades.create student_id: student_deactive.id, raw_points: 3, score: 8, student_visible: true
      expect(subject.earned_average).to eq 6
    end

    it "returns 0 if there are no grades" do
      expect(subject.earned_average).to be_zero
    end
  end

  describe "#earned_score_count" do
    before { subject.save }

    it "returns only student_visible grades" do
      subject.grades.create student_id: create(:user).id
      expect(subject.earned_score_count).to be_empty
    end

    it "returns the number of unique scores for each grade" do
      subject.grades.create student_id: student1.id, raw_points: 85, student_visible: true
      subject.grades.create student_id: student2.id, raw_points: 85, student_visible: true
      subject.grades.create student_id: student3.id, raw_points: 105, student_visible: true
      subject.grades.create student_id: student_deactive.id, raw_points: 65, student_visible: true
      expect(subject.earned_score_count).to eq({ 85 => 2, 105 => 1 })
    end
  end

  describe "#median" do
    before { subject.save }

    it "returns the median score for a graded grade" do
      subject.grades.create student_id: student1.id, raw_points: 8, score: 8, student_visible: true
      subject.grades.create student_id: student2.id, raw_points: 5, score: 8, student_visible: true
      subject.grades.create student_id: student_deactive.id, raw_points: 3, score: 8, student_visible: true
      expect(subject.median).to eq 6
    end

    it "returns 0 if there are no grades" do
      expect(subject.median).to be_zero
    end
  end

  describe "#high_score" do
    before { subject.save }

    it "returns the maximum raw score for a graded grade" do
      subject.grades.create student_id: student1.id, raw_points: 8, student_visible: true
      subject.grades.create student_id: student2.id, raw_points: 5, student_visible: true
      subject.grades.create student_id: student_deactive.id, raw_points: 3, student_visible: true
      expect(subject.high_score).to eq 8
    end
  end

  describe "#low_score" do
    before { subject.save }

    it "returns the minimum raw score for a graded grade" do
      subject.grades.create student_id: student1.id, raw_points: 8, student_visible: true
      subject.grades.create student_id: student2.id, raw_points: 5, student_visible: true
      subject.grades.create student_id: student_deactive.id, raw_points: 3, student_visible: true
      expect(subject.low_score).to eq 5
    end
  end

  describe "#predicted_count" do
    it "returns the number of grades that are predicted to have a score greater than zero" do
      predicted_earned_grades = double(:predicted_earned_grades, predicted_to_be_done: 43.times.to_a)
      allow(subject).to receive(:predicted_earned_grades).and_return predicted_earned_grades
      expect(subject.predicted_count).to eq 43
    end
  end

  describe "#grade_count" do
    before { subject.save }

    it "counts the number of grades that are student_visible" do
      subject.grades.create student_id: student1.id, raw_points: 85, student_visible: true
      subject.grades.create student_id: student2.id, raw_points: 85, student_visible: true
      subject.grades.create student_id: student_deactive.id, raw_points: 65, student_visible: true
      subject.grades.create student_id: student3.id, raw_points: 105
      expect(subject.grade_count).to eq 2
    end
  end

  describe "#student_visible_scores" do
    before { subject.save }

    it "returns an array raw graded scores" do
      subject.grades.create student_id: student1.id, raw_points: 85, student_visible: true
      subject.grades.create student_id: student_deactive.id, raw_points: 65, student_visible: true
      expect(subject.student_visible_scores).to eq([85])
    end
  end
end
