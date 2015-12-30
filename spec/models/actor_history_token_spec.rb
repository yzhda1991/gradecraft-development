require "active_record_spec_helper"
require "./app/models/actor_history_token"

describe ActorHistoryToken do
  describe ".tokenizable?" do
    it "is tokenizable if the key is an actor_id" do
      expect(described_class.tokenizable?("actor_id", nil)).to eq true
    end
  end

  describe ".token" do
    it "returns actor" do
      expect(described_class.token).to eq :actor
    end
  end

  describe "#parse" do
    let(:user) { create :user, first_name: "Jimmy", last_name: "Page" }
    let(:subject) { described_class.new "actor_id", user.id, Object }

    it "returns the name of the actor" do
      expect(subject.parse).to eq({ actor: "Jimmy Page" })
    end

    it "returns `Someone` if the user is not found" do
      subject = described_class.new "actor_id", 123, Object
      expect(subject.parse).to eq({ actor: "Someone" })
    end

    it "returns `You` if the user is the current user" do
      expect(subject.parse(current_user: user)).to eq({ actor: "You" })
    end
  end
end
