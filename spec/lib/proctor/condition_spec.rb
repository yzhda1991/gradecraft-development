describe Proctor::Condition do
  subject do
    described_class.new(name: "Some Name") do
      # this is the condition
      "some-value" == "some-different-thing"
    end
  end

  describe "#initialize" do
    it "takes a name as a required keyword argument" do
      expect(subject.name).to eq "Some Name"
    end

    it "converts the name into a string" do
      this_condition = described_class.new(name: :another_thing)
      expect(this_condition.name).to eq "another_thing"
    end

    it "takes a condition as a block but doesn't call it" do
      expect(subject.condition.class).to eq Proc
      expect(subject.condition.call).to eq false
    end
  end

  describe "readable attributes" do
    it "should have a readable condition" do
      subject.instance_variable_set(:@condition, "condition stuff")
      expect(subject.condition).to eq "condition stuff"
    end

    it "should have a readable name" do
      subject.instance_variable_set(:@name, "name stuff")
      expect(subject.name).to eq "name stuff"
    end
  end

  describe "#outcome" do
    it "calls the condition block" do
      expect(subject.outcome).to eq false
      expect(subject.outcome).to eq subject.condition.call
    end
  end

  describe "#failed?" do
    context "the condition returns a falsey value" do
      it "returns true" do
        allow(subject).to receive(:condition) { Proc.new { false } }
        expect(subject.failed?).to eq true
      end
    end

    context "the condition returns a truthy value" do
      it "returns false" do
        allow(subject).to receive(:condition) { Proc.new { true } }
        expect(subject.failed?).to eq false
      end
    end
  end

  describe "#passed?" do
    context "the condition returns a truthy value" do
      it "returns true" do
        allow(subject).to receive(:condition) { Proc.new { true } }
        expect(subject.passed?).to eq true
      end
    end

    context "the condition returns a truthy value" do
      it "returns false" do
        allow(subject).to receive(:condition) { Proc.new { false } }
        expect(subject.passed?).to eq false
      end
    end
  end
end
