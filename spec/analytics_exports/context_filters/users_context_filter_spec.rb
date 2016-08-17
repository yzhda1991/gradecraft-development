require "analytics/export"
require "./app/analytics_exports/context_filters/users_context_filter"

describe UsersContextFilter do
  subject { described_class.new context: context }
  let(:context) { double(:some_context, class: "CourseExportContext") }

  before do
    allow(subject).to receive(:valid_context_type?) { true }
  end

  it "inherits from Analytics::Export::ContextFilter" do
    expect(subject).to respond_to :validate_context_type
  end

  describe "#usernames" do
    it "builds a hash mapping id to name for each user" do
      users = [
        double(:user, id: 1, username: "archibald"),
        double(:user, id: 2, username: "beth")
      ]

      allow(subject.context).to receive(:users) { users }

      expect(subject.usernames).to eq({ 1 => "archibald", 2 => "beth" })
    end
  end
end
