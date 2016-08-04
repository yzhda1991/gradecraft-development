require "active_record_spec_helper"
require "./app/presenters/info/dashboard_course_events_presenter.rb"

describe Info::DashboardCourseEventsPresenter do
  let(:course) { create(:course) }
  let(:student) { create :student_course_membership, course: course }
  let(:event) { create :event, course: course }
  let(:event_with_open) { create :event, course: course, open_at: Date.yesterday }
  let(:assignment) { create :assignment, course: course, include_in_timeline: false, due_at: event.due_at }

  subject { described_class.new course: course, student: student, assignments: course.assignments }

  describe "#dates_for(event)" do
    it "returns the due dates to be displayed for a particular event" do
      expect(subject.dates_for(event)).to eq "Due: #{event.due_at}"
    end
    it "returns both the open at and the due at dates to be displayed for a particular event" do
      expect(subject.dates_for(event_with_open)).to eq "#{event_with_open.open_at} - #{event_with_open.due_at}"
    end
  end

  describe "#assignments_due_on(event)" do
    it "returns the assignments for the course that are also due on this day" do
      expect(subject.assignments_due_on(event)).to eq [assignment]
    end
  end
end
