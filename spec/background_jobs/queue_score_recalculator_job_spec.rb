describe QueueScoreRecalculatorJob do
  let(:course) { build_stubbed :course }
  let(:students) { build_stubbed_list :user, 2, role: :student, courses: [course] }

  describe ".perform" do
    let(:job) { instance_double "ScoreRecalculatorJob", enqueue: true }
    let!(:student_visible_grade) { build_stubbed :student_visible_grade, course: course, student: students.first }
    let!(:student_visible_badge) { build_stubbed :earned_badge, course: course, student_visible: true, student: students.second }

    before(:each) do
      allow(described_class).to receive(:updated_grades).and_return [student_visible_grade]
      allow(described_class).to receive(:updated_earned_badges).and_return [student_visible_badge]
      allow(ScoreRecalculatorJob).to receive(:new).and_return job
    end

    it "triggers the score recalculation job only for grades and earned badges updated within the last 24 hours" do
      expect(job).to receive(:enqueue).twice
      described_class.perform
    end
  end
end
