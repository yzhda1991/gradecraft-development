require "analytics"
require "rails_spec_helper"
require "./app/analytics_exports/export_contexts/course_export_context"
# 
describe CourseExportContext do
  subject { described_class.new course: course }
  let(:course) { create :course }

  it "has a readable course" do
    subject.instance_variable_set :@course, "some_course"
    expect(subject.course).to eq "some_course"
  end

  describe "#initialize" do
    it "accepts and sets a course" do
      expect(subject.course).to eq course
    end
  end

  describe "#events" do
    it "queries and caches events for the course" do
      allow(Analytics::Event).to receive(:where).with(course_id: course.id)
        .and_return ["event"]

      # it returns the event for the course
      expect(subject.events).to eq ["event"]

      # it sets the events array to @events
      expect(subject.instance_variable_get :@events).to eq ["event"]

      # and doesn't need to fetch it anymore
      expect(Analytics::Event).not_to receive(:where)
      subject.events
    end
  end

  describe "#predictor_events" do
    it "queries and caches predictor events for the course" do
      events = [
        double(:event, event_type: "predictor"),
        double(:event, event_type: "sumpin' else")
      ]

      allow(subject).to receive(:events) { events }

      expect(subject.predictor_events).to eq [events.first]
    end
  end

  describe "#user_pageviews" do
    it "fetches data for a CourseUserPageview aggregate and caches it" do
      allow(CourseUserPageview).to receive(:data) { { results: "pageview stuff" } }
      expect(CourseUserPageview).to receive(:data)
        .with(:all_time, nil, { course_id: course.id }, { page: "_all" })

      expect(subject.user_pageviews).to eq "pageview stuff"
    end
  end

  describe "#user_predictor_pageviews" do
    it "fetches data from the CourseUserPagePageview aggregate and caches it" do
      allow(CourseUserPagePageview).to receive(:data) { { results: "pageview stuff" } }
      expect(CourseUserPagePageview).to receive(:data)
        .with(:all_time, nil, { course_id: course.id }, { page: /predictor/ })

      expect(subject.user_predictor_pageviews).to eq "pageview stuff"
    end
  end

  describe "#user_logins" do
    it "fetches data from the CourseUserLogin aggregate and caches it" do
      allow(CourseUserLogin).to receive(:data) { { results: "login stuff" } }
      expect(CourseUserLogin).to receive(:data)
        .with(:all_time, nil, { course_id: course.id })

      expect(subject.user_logins).to eq "login stuff"
    end

    it "doesn't re-build cached logins" do
      # cache some hypothetical logins
      subject.instance_variable_set :@user_logins, ["some", "logins"]
      expect(CourseUserLogin).not_to receive(:data)
      subject.user_logins
    end
  end

  describe "#users" do
    let(:users) { create_list :user, 2 }

    it "queries Postgres for a collection of users with a course event" do
      events = [
        double(:event, user_id: users.first.id),
        double(:event, user_id: users.last.id)
      ]

      allow(subject).to receive(:events) { events }

      expect(subject.users.map(&:id).sort).to eq users.map(&:id).sort
    end
  end

  describe "#assignments" do
    let(:assignments) { create_list :assignment, 2 }

    it "queries Postgres for a collection of assignments with a course event" do
      events = [
        double(:event, assignment_id: assignments.first.id),
        double(:event, assignment_id: assignments.last.id)
      ]

      allow(subject).to receive(:events) { events }

      expect(subject.assignments.map(&:id).sort).to eq assignments.map(&:id).sort
    end
  end
end
