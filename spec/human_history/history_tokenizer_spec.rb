describe HumanHistory::HistoryTokenizer do
  it "initializes with a changeset" do
    changeset = { "name" =>  ["Bill", "Jimmy"] }

    expect(described_class.new(changeset).changeset).to eq changeset
  end

  it "does not have any tokens until it is analyzed" do
    changeset = { "name" =>  ["Bill", "Jimmy"] }

    expect(described_class.new(changeset).tokens).to be_empty
  end

  describe "#tokenize" do
    it "adds an actor token when an actor id is included in the changeset" do
      changeset = { "actor_id" => 123 }

      subject = described_class.new(changeset).tokenize

      expect(subject.tokens.length).to eq 1
      expect(subject.tokens.first).to be_kind_of HumanHistory::ActorHistoryToken
    end

    it "adds an event token when an event is included in the changeset" do
      changeset = { "event" => "update" }

      subject = described_class.new(changeset).tokenize

      expect(subject.tokens.length).to eq 1
      expect(subject.tokens.first).to be_kind_of HumanHistory::EventHistoryToken
    end

    it "adds a date token when an recorded at is included in the changeset" do
      changeset = { "recorded_at" => DateTime.new(2015, 4, 12, 1, 23) }

      subject = described_class.new(changeset).tokenize

      expect(subject.tokens.length).to eq 2
      expect(subject.tokens.first).to be_kind_of HumanHistory::DateHistoryToken
    end

    it "adds a time token when an recorded at is included in the changeset" do
      changeset = { "recorded_at" => DateTime.new(2015, 4, 12, 1, 23) }

      subject = described_class.new(changeset).tokenize

      expect(subject.tokens.length).to eq 2
      expect(subject.tokens.last).to be_kind_of HumanHistory::TimeHistoryToken
    end

    it "adds a change when a change is included in the changeset" do
      changeset = { "name" => ["Bill", "Jimmy"] }

      subject = described_class.new(changeset).tokenize

      expect(subject.tokens.length).to eq 1
      expect(subject.tokens.first).to be_kind_of HumanHistory::ChangeHistoryToken
    end

    it "adds a change when a created at is included in the changeset" do
      changeset = { "created_at" => [nil, DateTime.now] }

      subject = described_class.new(changeset).tokenize

      expect(subject.tokens.length).to eq 1
      expect(subject.tokens.first).to be_kind_of HumanHistory::CreatedHistoryToken
    end
  end
end
