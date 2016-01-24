require "./app/models/history_filter"

describe HistoryFilter do
  it "initializes with the changeset passed in" do
    changeset = [{ "event" => "blah" }, { "event" => "bleh" }, {}]
    expect(described_class.new(changeset).changeset).to eq changeset
  end

  describe "#empty_changeset?" do
    it "is not empty if none of the values are arrays which represent changes" do
      changeset = [{ "change" => ["before", "after"] }]
      expect(described_class.new(changeset).empty_changeset?(changeset.first)).to eq false
    end

    it "is empty if none of the values are arrays which represent changes" do
      changeset = [{ "event" => "blah" }]
      expect(described_class.new(changeset).empty_changeset?(changeset.first)).to eq true
    end
  end

  describe "#exclude" do
    it "filters a changeset by event type" do
      changeset = [{ "event" => "blah", "change" => ["before", "after"] },
                   { "event" => "bleh", "change" => ["before", "after"] }, {}]
      result = described_class.new(changeset).exclude("event" => "blah").changeset
      expect(result).to eq [{ "event" => "bleh", "change" => ["before", "after"] }]
    end

    it "filters a changeset by object" do
      changeset = [{ "event" => "blah", "object" => "Grade",
                     "change" => ["before", "after"] },
                   { "event" => "bleh", "change" => ["before", "after"] }, {}]
      result = described_class.new(changeset).exclude("object" => "Grade").changeset
      expect(result).to eq [{ "event" => "bleh", "change" => ["before", "after"] }]
    end

    it "filters a changeset via a block" do
      changeset = [{ "event" => "blah", "object" => "Grade",
                     "change" => ["before", "after"] },
                   { "event" => "bleh", "change" => ["before", "after"] }, {}]
      result = described_class.new(changeset).exclude { |changeset|
        changeset["object"] == "Grade"
      }.changeset
      expect(result).to eq [{ "event" => "bleh", "change" => ["before", "after"] }]
    end
  end

  describe "#include" do
    it "includes a changeset by event type" do
      changeset = [{ "event" => "blah", "change" => ["before", "after"] },
                   { "event" => "bleh", "change" => ["before", "after"] }, {}]
      result = described_class.new(changeset).include("event" => "blah").changeset
      expect(result).to eq [{ "event" => "blah", "change" => ["before", "after"] }]
    end

    it "includes a changeset by object" do
      changeset = [{ "event" => "blah", "object" => "Grade",
                     "change" => ["before", "after"] },
                   { "event" => "bleh", "change" => ["before", "after"] }, {}]
      result = described_class.new(changeset).include("object" => "Grade").changeset
      expect(result).to eq [{ "event" => "blah", "object" => "Grade",
                              "change" => ["before", "after"] }]
    end

    it "filters a changeset via a block" do
      changeset = [{ "event" => "blah", "object" => "Grade",
                     "change" => ["before", "after"] },
                   { "event" => "bleh", "change" => ["before", "after"] }, {}]
      result = described_class.new(changeset).include { |changeset|
        changeset["object"] == "Grade"
      }.changeset
      expect(result).to eq [{ "event" => "blah", "object" => "Grade",
                              "change" => ["before", "after"] }]
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
