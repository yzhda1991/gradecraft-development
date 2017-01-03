require "./app/presenters/info/dashboard_weekly_stats_presenter"

describe Info::DashboardWeeklyStatsPresenter do
  let(:course) { create(:course) }
  let(:assignment) { create(:assignment, assignment_type: assignment_type) }
  let(:another_assignment) { create(:assignment, assignment_type: another_assignment_type) }
  let(:assignment_type) { create(:assignment_type, course: course) }
  let(:another_assignment_type) { create(:assignment_type, course: course) }
  let(:student) { create(:course_membership, :student, course: course).user }
  let!(:submission) { create(:submission, course: course, assignment: assignment) }
  let!(:draft_submission) { create(:draft_submission, course: course, assignment: another_assignment) }

  subject { described_class.new course: course }

  describe "#submitted_assignment_types_this_week" do
    it "returns only the submitted non-draft submissions in the past week" do
      expect(subject.submitted_assignment_types_this_week.count).to eq 1
      expect(subject.submitted_assignment_types_this_week).to eq [assignment_type]
    end
  end

  describe "#submitted_submissions_this_week_count" do
    it "returns a count of the non-draft submissions in the past week" do
      allow(Submission).to receive(:submitted_this_week).with(assignment_type).and_return [submission]
      expect(subject.submitted_submissions_this_week_count(assignment_type)).to eq 1
    end
  end
end
