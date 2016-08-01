require "analytics"
require "./app/analytics_aggregates/course_user_pageview"
require "./app/analytics_aggregates/course_user_page_pageview"
require "./app/analytics_aggregates/course_user_login"
require "./app/analytics_exports/export_contexts/course_export_context"
require "active_record_spec_helper"

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
      allow(Analytics::Event).to receive(:where)
        .with(course_id: 5, event_type: "predictor") { ["predictor_event"] }

      # it returns the predictor event for the course
      expect(subject.predictor_events).to eq ["predictor_event"]

      # it sets the predictor events array to @preditor_events
      expect(subject.instance_variable_get :@predictor_events)
        .to eq ["predictor_event"]

      # and doesn't need to fetch it anymore
      expect(Analytics::Event).not_to receive(:where)
      subject.predictor_events
    end
  end

  describe "#user_pageviews" do
    it "fetches data for a CourseUserPageview aggregate and caches it" do
      allow(CourseUserPageview).to receive(:data)
        .with(:all_time, nil, { course_id: 5 }, { page: "_all" })
        .and_return ["user_pageview"]

      # it returns a list of user pageview events for the course
      expect(subject.user_pageviews).to eq ["user_pageview"]

      # it sets them to @user_pageviews
      expect(subject.instance_variable_get :@user_pageviews)
        .to eq ["user_pageview"]

      # and considers them cached
      expect(CourseUserPageview).not_to receive(:data)
      subject.user_pageviews
    end
  end

  describe "#user_predictor_pageviews" do
    it "fetches data from the CourseUserPagePageview aggregate and caches it" do
      allow(CourseUserPagePageview).to receive(:data)
        .with(:all_time, nil, { course_id: 5 , page: /predictor/ })
        .and_return ["user_predictor_pageview"]

      # it returns a list of user predictor pageview events for the course
      expect(subject.user_predictor_pageviews).to eq ["user_predictor_pageview"]

      # it sets them to @user_predictor_pageviews
      expect(subject.instance_variable_get :@user_predictor_pageviews)
        .to eq ["user_predictor_pageview"]

      # and considers them cached
      expect(CourseUserPagePageview).not_to receive(:data)
      subject.user_predictor_pageviews
    end
  end

  describe "#user_logins" do
    it "fetches data from the CourseUserLogin aggregate and caches it" do
      expect(CourseUserLogin).to receive(:data)
        .with(:all_time, nil, { course_id: course.id })

      expect(subject.instance_variable_get :@user_logins)
        .to eq subject.user_logins
    end

    it "doesn't re-build cached logins" do
      # cache some hypothetical logins
      subject.instance_variable_set :@user_logins, ["some", "logins"]
      expect(CourseUserLogin).not_to receive(:data)
      subject.user_logins
    end
  end

  describe "#users" do
    it "fetches all users with ids matching the user_ids array" do
      users = create_list :user, 2
      allow(subject).to receive(:user_ids) { users.collect(&:id) }
      expect(subject.users).to include users.first, users.last
    end

    it "doesn't re-fetch the cached users" do
      subject.instance_variable_set :@users, ["some", "users"]
      expect(User).not_to receive(:where)
      subject.users
    end
  end

  describe "#user_ids" do
    it "builds an array of unique user_ids from the fetched events and caches it" do
      events = [
        double(:event, user_id: 1),
        double(:event, user_id: 2),
        double(:event, user_id: 2)
      ]

      allow(subject).to receive(:events) { events }
      expect(subject.user_ids).to eq [1, 2]
    end

    it "doesn't re-build the user_ids array if cached" do
      subject.instance_variable_set :@user_ids, [1, 2, 3]
      expect(subject).not_to receive(:events)
      subject.user_ids
    end
  end

  describe "#assignment_ids" do
    it "builds an array of all unique event assignment_ids and caches it" do
      pending
    end
  end
end
