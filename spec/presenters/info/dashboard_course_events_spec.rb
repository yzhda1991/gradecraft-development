describe Info::DashboardCourseEventsPresenter do
  let(:course) { create(:course) }
  let(:student) { build_stubbed(:user) }
  let(:event) { create :event, course: course }
  let(:event_with_open) { create :event, course: course, open_at: Date.yesterday }
  let(:assignment) { create :assignment, course: course, due_at: event.due_at }

  subject { described_class.new course: course, student: student, assignments: course.assignments }

  describe "#assignments_due_on(event)" do
    it "returns the assignments for the course that are also due on this day" do
      expect(subject.assignments_due_on(event)).to eq [assignment]
    end
  end
end
