describe Info::DashboardCoursePlannerPresenter do
  let(:assignment) { build(:assignment) }
  let(:course) { assignment.course }
  let(:student) { build_stubbed(:user) }

  subject { described_class.new course: course, student: student, assignments: course.assignments }

  describe "#submitted_submissions_count" do
    let!(:draft_submission) { create(:draft_submission, course: course, assignment: assignment) }
    let!(:submitted_submission) { create(:submission, course: course, assignment: assignment) }

    it "returns a count for only non-draft submissions" do
      expect(subject.submitted_submissions_count(assignment)).to eq 1
    end
  end
end
