require "analytics"
require "./app/analytics_exports/export_contexts/course_export_context"

describe CourseExportContext do
  subject { described_class.new course: course }
  let(:course) { double(:course, id: 5) }

  it "has a readable course" do
    subject.instance_variable_set :@course, "some_course"
    expect(subject.course).to eq "some_course"
  end

  describe "#initialize" do
    it "accepts and sets a course" do
      expect(subject.course).to eq course
    end
  end

  describe "#export_data" do
    let(:stubbed_attrs) do
      {
        events: ["event"],
        predictor_events: ["predictor_event"],
        user_pageviews: { results: ["user_pageview"] },
        user_predictor_pageviews: { results: ["user_predictor_pageview"] },
        user_logins: { results: ["user_logins"] },
        users: ["user"],
        assignments: ["assignment"]
      }
    end

    before { allow(subject).to receive_messages(stubbed_attrs) }

    it "builds and caches an @export_data hash" do
      # note that the aggregate records have been collapsed down to provide
      # the value of the :results hash rather than the hash itself
      #
      expected_result = {
        events: ["event"],
        predictor_events: ["predictor_event"],
        user_pageviews: ["user_pageview"],
        user_predictor_pageviews: ["user_predictor_pageview"],
        user_logins: ["user_logins"],
        users: ["user"],
        assignments: ["assignment"]
      }

      # the output should have provided the result
      expect(subject.export_data).to eq expected_result

      # and it should have been set to @export_data
      expect(subject.instance_variable_get :@export_data).to eq expected_result

      # and now that it's cached it shouldn't have to query anything again
      expect(subject).not_to receive(:events)
      subject.export_data
    end
  end

  describe "#events" do
    it "queries and caches events for the course" do
      allow(Analytics::Event).to receive(:where).with(course_id: 5)
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
    end
  end

  describe "#user_pageviews" do
    it "fetches data for a CourseUserPageview aggregate and caches it" do
    end
  end

  describe "#user_predictor_pageviews" do
    it "fetches data from the CourseUserPagePageview aggregate and caches it" do
    end
  end

  describe "#user_logins" do
    it "fetches data from the CourseUserLogin aggregate and caches it" do
    end
  end

  describe "#users" do
    it "fetches all users with ids matching the user_ids array" do
    end
  end

  describe "#user_ids" do
    it "builds an array of user_ids from the fetched events and caches it" do
    end
  end

  describe "#assignment_ids" do
    it "builds an array of all unique event assignment_ids and caches it" do
    end
  end
end
