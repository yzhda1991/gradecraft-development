describe HumanHistory::HistoryTokenRegistry do
  before { described_class.clear }

  describe ".register" do
    it "adds the token type to the registry" do
      described_class.register HumanHistory::ActorHistoryToken, ->(key, value, set) { key == "actor_id" }

      expect(described_class.registered_tokens.length).to eq 1
      expect(described_class.registered_tokens.first.type).to eq HumanHistory::ActorHistoryToken
    end

    it "does not register the same token type twice" do
      described_class.register HumanHistory::ActorHistoryToken, ->(key, value, set) { key == "actor_id" }
      described_class.register HumanHistory::ActorHistoryToken, ->(key, value, set) { key == "actor_id" }

      expect(described_class.registered_tokens.length).to eq 1
    end

    it "adds the selector from the type if it responds to `tokenizable`" do
      class TestToken
        def self.tokenizable?(key, value, changeset); end
      end

      described_class.register TestToken
      expect(described_class.registered_tokens.length).to eq 1
      expect(described_class.registered_tokens.first.selector).to be_kind_of Proc
    end
  end

  describe ".unregister" do
    it "removes the token type from the registry" do
      described_class.register HumanHistory::ActorHistoryToken, ->(key, value, set) { key == "actor_id" }
      described_class.unregister HumanHistory::ActorHistoryToken

      expect(described_class.registered_tokens).to be_empty
    end
  end

  describe ".for" do
    it "returns the tokens for the provided selector" do
      described_class.register HumanHistory::ActorHistoryToken, ->(key, value, set) { key == "actor_id" }

      expect(described_class.for("actor_id", nil, nil).map(&:type)).to \
        eq [HumanHistory::ActorHistoryToken]
    end

    it "returns an empty array if the selector is not found" do
      described_class.register HumanHistory::ActorHistoryToken, ->(key, value, set) { key == "actor_id" }

      expect(described_class.for("blah", nil, nil)).to be_empty
    end
  end
end
