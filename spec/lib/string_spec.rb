describe Gradecraft::String do
  describe "#past_tense" do
    it "adds a 'd' to the end of the string if it ends in an 'e'" do
      expect(described_class.new("create").past_tense).to eq "created"
    end

    it "adds an 'ed' to the end of the string if it ends in a 'd'" do
      expect(described_class.new("poop").past_tense).to eq "pooped"
    end
  end

  describe "#to_s" do
    it "returns a string representation" do
      expect(described_class.new(123).to_s).to eq "123"
    end
  end

  describe "#==" do
    it "returns true for other strings" do
      expect(described_class.new("blah") == "blah").to eq true
    end

    it "returns true for values that respond to to_s" do
      expect(described_class.new(123) == "123").to eq true
    end

    it "returns true using eql method" do
      expect(described_class.new("blah")).to eq "blah"
    end
  end

  describe "#method_missing" do
    it "returns the same thing a string would" do
      expect(described_class.new("123").chars).to eq ["1", "2", "3"]
    end

    it "wraps the result in this string class for chaining" do
      expect(described_class.new("blah").capitalize).to be_a_kind_of described_class
    end

    it "raises a NoMethodError if the method is not defined on string" do
      expect { described_class.new("123").blah }.to raise_error NoMethodError
    end
  end

  describe "#respond_to_missing?" do
    it "responds to the string interface" do
      expect(described_class.new("123").respond_to?(:chars)).to eq true
    end
  end
end
