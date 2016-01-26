RSpec.shared_examples "a historical model" do |fixture, updated_attributes|
  let(:model) { build fixture }

  describe "versioning", versioning: true do
    before { model.save }

    it "is enabled for a #{fixture}" do
      expect(PaperTrail).to be_enabled
      expect(model).to be_versioned
    end

    it "creates a version when the #{fixture} is created" do
      expect(model.versions.count).to eq 1
    end
  end

  describe "#has_history?", versioning: true do
    it "returns false if there is no history" do
      expect(model).to_not have_history
    end

    it "returns true if there is history" do
      model.save
      expect(model).to have_history
    end
  end

  describe "#history", versioning: true do
    let(:user) { create :user }

    before do
      PaperTrail.whodunnit = user.id
      model.save
    end

    it "returns the history for the created #{fixture}" do
      expect(model.history.length).to eq 1
      expect(model.history.first.changeset.keys).to include("created_at")
      expect(model.history.first.changeset).to include({ "object" => described_class.name })
      expect(model.history.first.changeset).to include({ "event" => "create" })
      expect(model.history.first.changeset).to include({ "actor_id" => user.id.to_s })
      expect(model.history.first.changeset).to include({ "recorded_at" => model.versions.last.created_at })
    end

    it "returns the changesets for an updated #{fixture}" do
      model.update_attributes updated_attributes
      expect(model.history.length).to eq 2
      updated_attributes.each do |key, value|
        expect(model.history.first.changeset).to include({ key.to_s => [nil, value] })
      end
      expect(model.history.first.changeset).to include({ "object" => described_class.name })
      expect(model.history.first.changeset).to include({ "event" => "update" })
      expect(model.history.first.changeset).to include({ "actor_id" => user.id.to_s })
      expect(model.history.first.changeset).to include({ "recorded_at" => model.versions.last.created_at })
    end

    it "orders the changesets so the newest changes are at the top" do
      model.update_attributes updated_attributes
      expect(model.history.length).to eq 2
      expect(model.history.first.changeset["event"]).to eq "update"
      expect(model.history.last.changeset["event"]).to eq "create"
    end
  end

  describe "#historical_merge", versioning: true do
    let(:another_model) { build fixture }

    it "returns new history with 2 histories for 2 creation events" do
      model.save
      another_model.save

      history = model.historical_merge(another_model)

      expect(history.length).to eq 2
      expect(history.first.changeset["id"].last).to eq another_model.id
      expect(history.last.changeset["id"].last).to eq model.id
    end
  end
end
