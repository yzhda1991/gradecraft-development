require "./app/models/history_filter"

describe HistoryFilter do
  it "initializes with the changeset passed in" do
    changeset = [{ "event" => "blah" }, { "event" => "bleh" }, {}]
    expect(described_class.new(changeset).changeset).to eq changeset
  end

  describe "#exclude" do
    it "filters a changeset by event type" do
      changeset = [{ "event" => "blah" }, { "event" => "bleh" }, {}]
      result = described_class.new(changeset).exclude("event" => "blah").changeset
      expect(result).to eq [{ "event" => "bleh" }]
    end

    it "filters a changeset by object" do
      changeset = [{ "event" => "blah", "object" => "Grade" }, { "event" => "bleh" }, {}]
      result = described_class.new(changeset).exclude("object" => "Grade").changeset
      expect(result).to eq [{ "event" => "bleh" }]
    end
  end

  describe "#include" do
    it "includes a changeset by event type" do
      changeset = [{ "event" => "blah" }, { "event" => "bleh" }, {}]
      result = described_class.new(changeset).include("event" => "blah").changeset
      expect(result).to eq [{ "event" => "blah" }]
    end

    it "includes a changeset by object" do
      changeset = [{ "event" => "blah", "object" => "Grade" }, { "event" => "bleh" }, {}]
      result = described_class.new(changeset).include("object" => "Grade").changeset
      expect(result).to eq [{ "event" => "blah", "object" => "Grade" }]
    end
  end

  describe "#remove" do
    it "filters a changeset by the changes" do
      changeset = [{ "attr" => ["value1", "value2"], "attr2" => ["value3", "value4"] }]
      result = described_class.new(changeset).remove("name" => "attr2").changeset
      expect(result).to eq [{ "attr" => ["value1", "value2"] }]
    end

    it "removes the whole changeset if it's empty after the removal" do
      changeset = [{ "attr" => ["value1", "value2"] }, { "attr2" => ["value3", "value4"] }]
      result = described_class.new(changeset).remove("name" => "attr2").changeset
      expect(result).to eq [{ "attr" => ["value1", "value2"] }]
    end
  end
end
