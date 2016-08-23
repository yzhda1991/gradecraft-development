require "analytics/export"
require "./app/analytics_exports/context_filters/user_aggregate_context_filter"

describe UserAggregateContextFilter do
  subject { described_class.new context }
  let(:context) { double(:some_context, class: "CourseExportContext") }

  before do
    allow(subject).to receive(:valid_context_type?) { true }
  end

  it "inherits from Analytics::Export::ContextFilter" do
    expect(subject).to respond_to :validate_context_type
  end

  describe "#user_roles" do
    it "builds a hash mapping user_id to user_role for each event" do
      events = [
        double(:event, user_id: 1, user_role: "hedgehog"),
        double(:event, user_id: 2, user_role: "badger")
      ]

      allow(subject.context).to receive(:events) { events }

      expect(subject.user_roles).to eq({ 1 => "hedgehog", 2 => "badger" })
    end
  end

  describe "#user_predictor_event_counts" do
    it "builds a hash with a count of total predictor events by user_id" do
      events = []
      3.times { events << double(:event, user_id: 1) }
      5.times { events << double(:event, user_id: 2) }

      allow(subject.context).to receive(:predictor_events) { events }

      expect(subject.user_predictor_event_counts).to eq({ 1 => 3, 2 => 5 })
    end
  end

  describe "#parsed_user_pageviews" do
    it "builds a hash of user_ids mapped to all-time user pageviews" do
      aggregate_results = []

      aggregate_results << double(:result, \
        user_id: 1,
        raw_attributes: { "pages" => { "_all" => { "all_time" => 200 } } })

      aggregate_results << double(:result, \
        user_id: 2,
        raw_attributes: { "pages" => { "_all" => { "all_time" => 300 } } })

      allow(subject.context).to receive(:user_pageviews) { aggregate_results }

      expect(subject.parsed_user_pageviews).to eq({ 1 => 200, 2 => 300 })
    end
  end

  describe "#parsed_user_logins" do
    it "builds a hash of user_ids mapped to all-time user logins" do
      logins = []
      logins << double(:login, user_id: 1, "[]": { "count" => 200 })
      logins << double(:login, user_id: 2, "[]": { "count" => 400 })

      allow(subject.context).to receive(:user_logins) { logins }

      expect(subject.parsed_user_logins).to eq({ 1 => 200, 2 => 400 })
    end
  end

  describe "#user_predictor_sessions" do
    it "builds a hash of user_ids mapped to all-time user logins" do
      pageviews = []
      pageviews << double(:pageview, user_id: 10, "[]": 2000)
      pageviews << double(:pageview, user_id: 20, "[]": 4000)

      allow(subject.context).to receive(:user_predictor_pageviews) { pageviews }

      expect(subject.user_predictor_sessions).to eq({ 10 => 2000, 20 => 4000 })
    end
  end

end
