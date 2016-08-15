require "analytics/export"
require "./app/analytics_exports/context_filters/user_aggregate_context_filter"

describe UserAggregateContextFilter do
  subject { described_class.new context: context }
  let(:context) { double(:some_context, class: "CourseExportContext") }

  before do
    allow(subject).to receive(:valid_context_type?) { true }
  end

  it "inherits from Analytics::Export::ContextFilter" do
    expect(subject).to respond_to :validate_context_type
  end

  describe "#roles" do
    it "builds a hash mapping user_id to user_role for each event" do
      events = [
        double(:event, user_id: 1, user_role: "hedgehog"),
        double(:event, user_id: 2, user_role: "badger")
      ]

      allow(subject.context).to receive(:events) { events }

      expect(subject.roles).to eq({ 1 => "hedgehog", 2 => "badger" })
    end
  end
end
