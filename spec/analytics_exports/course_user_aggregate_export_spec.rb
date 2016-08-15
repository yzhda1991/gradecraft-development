require "analytics"
require "./app/analytics_exports/course_user_aggregate_export"
require "./app/analytics_exports/context_filters/user_aggregate_context_filter"

describe CourseUserAggregateExport do
  subject { described_class.new context: context }
  let(:context) { double(:some_context, class: "SomeClass").as_null_object }
  let(:context_filter) { double(:some_context_filter).as_null_object }

  before do
    allow(subject).to receive(:context_filter) { context_filter }
  end

  it "includes Analytics::Export::Model" do
    expect(subject.class).to respond_to(:column_mapping)
  end

  it "uses events as the focus of the export" do
    expect(described_class.instance_variable_get :@export_focus).to eq :users
  end

  it "has a column mapping" do
    expect(described_class.instance_variable_get :@column_mapping).to eq(
      {
        username: :username,
        role: :user_role,
        user_id: :id,
        total_pageviews: :pageviews,
        total_logins: :logins,
        total_predictor_events: :predictor_events,
        total_predictor_sessions: :predictor_sessions
      }
    )
  end

  describe "#user_role" do
    it "takes the user_role from context_filter#roles" do
      allow(context_filter).to receive(:roles).and_return({ 20 => "admin" })

      user = double(:user, id: 20)
      expect(subject.user_role user).to eq "admin"
    end
  end

  describe "#pageviews" do
    it "takes the pageviews from context_filter#parsed_user_pageviews" do
      allow(context_filter).to receive(:parsed_user_pageviews).and_return({ 20 => 400 })

      user = double(:user, id: 20)
      expect(subject.pageviews user).to eq 400
    end
  end

  describe "#logins" do
    it "takes the logins from context_filter#user_logins" do
      allow(context_filter).to receive(:user_logins).and_return({ 20 => 400 })

      user = double(:user, id: 20)
      expect(subject.logins user).to eq 400
    end
  end

  describe "#predictor_events" do
    it "takes the predictor_events from context_filter#user_predictor_event_counts" do
      allow(context_filter).to receive(:user_predictor_event_counts).and_return({ 20 => 400 })

      user = double(:user, id: 20)
      expect(subject.predictor_events user).to eq 400
    end
  end

  describe "#predictor_sessions" do
    it "takes the predictor_sessions from context_filter#user_predictor_sessions" do
      allow(context_filter).to receive(:user_predictor_sessions).and_return({ 20 => 400 })

      user = double(:user, id: 20)
      expect(subject.predictor_sessions user).to eq 400
    end
  end

  describe "#context_filter" do
    it "builds a new context filter using the given context" do
      allow(subject).to receive(:context_filter).and_call_original

      context_filter = subject.context_filter
      expect(context_filter.class).to eq UserAggregateContextFilter
      expect(context_filter.context).to eq context
    end
  end
end
