require "analytics"
require "./app/analytics_exports/course_user_aggregate_export"
require "./app/analytics_exports/context_filters/user_aggregate_context_filter"

describe CourseUserAggregateExport do
  subject { described_class.new context: context }
  let(:context) { double(:some_context, class: "SomeClass").as_null_object }
  let(:context_filters) do
    { user_aggregate: double(:filter).as_null_object }
  end

  before do
    allow(subject).to receive(:context_filters) { context_filters }
  end

  it "includes Analytics::Export::Model" do
    expect(subject.class).to respond_to(:column_mapping)
  end

  it "uses events as the focus of the export" do
    expect(described_class.instance_variable_get :@export_focus).to eq :users
  end

  it "uses the users context filter" do
    filter_names = described_class.instance_variable_get :@context_filter_names
    expect(filter_names).to eq [:user_aggregate]
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
      allow(context_filters[:user_aggregate])
        .to receive(:user_roles).and_return({ 20 => "admin" })

      user = double(:user, id: 20)
      expect(subject.user_role user).to eq "admin"
    end
  end

  describe "#pageviews" do
    it "takes the pageviews from context_filter#parsed_user_pageviews" do
      allow(context_filters[:user_aggregate])
        .to receive(:parsed_user_pageviews).and_return({ 20 => 400 })

      user = double(:user, id: 20)
      expect(subject.pageviews user).to eq 400
    end
  end

  describe "#logins" do
    it "takes the logins from context_filter#user_logins" do
      allow(context_filters[:user_aggregate])
        .to receive(:user_logins).and_return({ 20 => 400 })

      user = double(:user, id: 20)
      expect(subject.logins user).to eq 400
    end
  end

  describe "#predictor_events" do
    it "takes the predictor_events from context_filter#user_predictor_event_counts" do
      allow(context_filters[:user_aggregate])
        .to receive(:user_predictor_event_counts).and_return({ 20 => 400 })

      user = double(:user, id: 20)
      expect(subject.predictor_events user).to eq 400
    end
  end

  describe "#predictor_sessions" do
    it "takes the predictor_sessions from context_filter#user_predictor_sessions" do
      allow(context_filters[:user_aggregate])
        .to receive(:user_predictor_sessions).and_return({ 20 => 400 })

      user = double(:user, id: 20)
      expect(subject.predictor_sessions user).to eq 400
    end
  end
end
