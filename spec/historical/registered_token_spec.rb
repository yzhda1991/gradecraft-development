require "spec_helper"
require "./lib/historical/actor_history_token"
require "./lib/historical/registered_token"

describe RegisteredToken do
  describe "#create" do
    subject { described_class.new ActorHistoryToken, ->(key, value) { true } }

    it "creates an object of the registered type with a key and value" do
      result = subject.create(:key, :value, Object)
      expect(result).to be_kind_of ActorHistoryToken
    end
  end
end
