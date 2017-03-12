describe HumanHistory::DefaultChangeDescriptionFormatter do
  let(:attribute) { "attribute" }
  let(:changes) { ["previous", "current"] }
  let(:type) { "Object" }

  subject { described_class.new attribute, changes, type }

  describe "#initialize" do
    it "is initialized with an attribute" do
      expect(subject.attribute).to eq attribute
    end

    it "is initialized with the changes" do
      expect(subject.changes).to eq changes
    end

    it "is initialized with the type" do
      expect(subject.type).to eq type
    end
  end

  describe "#formattable?" do
    it "returns true" do
      expect(subject).to be_formattable
    end
  end

  describe "#change_description" do
    class Object
      extend ActiveModel::Translation
    end

    it "returns the attribute name and changes" do
      expect(subject.change_description).to eq "the attribute from \"previous\" to \"current\""
    end

    it "does not include a 'from' if the previous value was nil" do
      subject = described_class.new "blah_date", [nil, "new"], "Object"

      expect(subject.change_description).to eq "the blah date to \"new\""
    end

    it "does not include a 'from' if the previous value was empty" do
      subject = described_class.new "blah_date", ["", "new"], "Object"

      expect(subject.change_description).to eq "the blah date to \"new\""
    end

    it "does not place quotes around integer changes" do
      subject = described_class.new "blah_date", [123, "new"], "Object"

      expect(subject.change_description).to eq "the blah date from 123 to \"new\""
    end

    it "does not place quotes around boolean changes" do
      subject = described_class.new "blah_date", [false, true], "Object"

      expect(subject.change_description).to eq "the blah date from false to true"
    end
  end
end
