require "spec_helper"
require "./app/models/history_tokenizer"
require "./app/models/registered_token"

describe RegisteredToken do
  describe "#create" do
    subject { described_class.new ActorHistoryToken, ->(key, value) { true } }

    it "creates an object of the registered type with a key and value" do
      result = subject.create(:key, :value, Object)
      expect(result).to be_kind_of ActorHistoryToken
    end
  end
end
