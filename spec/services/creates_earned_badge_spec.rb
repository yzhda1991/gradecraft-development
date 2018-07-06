describe Services::CreatesEarnedBadge do
  describe ".call" do
    let(:course) { create :course }
    let(:badge) { create :badge }
    let(:student) { create(:course_membership, :student, course: course).user}
    let(:grade) { create :grade, course: course, student: student }
    let(:professor) { create(:course_membership, :professor, course: course).user}
    let(:result) { described_class.execute attributes: attributes }


    let(:attributes) do
      {
        student_id: student.id,
        badge_id: badge.id,
        grade_id: grade.id,
        course_id: course.id,
        awarded_by_id: professor.id,
        feedback: "You are so awesome!"
      }
    end

    before do
      class FakeJob
        def initialize(attributes); end
        def enqueue; end
      end

      stub_const("ScoreRecalculatorJob", FakeJob)
    end

    it "creates a new earned badge" do
      expect(Services::Actions::CreatesEarnedBadge).to \
        receive(:execute).and_call_original
      described_class.call attributes
    end

    it "recalculates the student's score" do
      expect(Services::Actions::RecalculatesStudentScore).to \
        receive(:execute).and_call_original
      described_class.call attributes
    end

    it "notifies the student of the awarded badge" do
      expect(Services::Actions::NotifiesOfEarnedBadge).to \
        receive(:execute).and_call_original
      described_class.call attributes
    end
  end
end
