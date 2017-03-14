describe Analytics::Errors::InvalidParsingStrategy do
  subject do
    described_class.new \
      parsing_strategy: "some_strategy",
      record: record,
      export: export,
      message: "some-message"
  end

  let(:record) { double(:record, class: "SomeClass").as_null_object }
  let(:export) { double(:export, class: "AnotherClass").as_null_object }

  it "inherits from StandardError" do
    expect(described_class.superclass).to eq StandardError
  end

  describe "#initialize" do
    it "sets a parsing strategy" do
      expect(subject.parsing_strategy).to eq "some_strategy"
    end

    it "sets a record" do
      expect(subject.record).to eq record
    end

    it "sets an export" do
      expect(subject.export).to eq export
    end

    it "sets an optional message" do
      expect(subject.message).to eq "some-message"
    end
  end

  describe "#to_s" do
    it "renders the given message if there is one" do
      expect(subject.to_s).to eq "some-message"
    end

    it "renders the default message if no @message is set" do
      subject.instance_variable_set :@message, nil
      allow(subject).to receive(:default_message) { "the-default" }
      expect(subject.to_s).to eq "the-default"
    end
  end

  describe "#default_message" do
    it "includes the parsing strategy" do
      expect(subject.default_message)
        .to include(subject.parsing_strategy.inspect)
    end

    it "includes the inspected export class" do
      expect(subject.default_message)
        .to include(subject.export.class.inspect)
    end

    it "includes the inspected record class" do
      expect(subject.default_message)
        .to include(subject.record.class.inspect)
    end

    it "has some other snazzy explanation" do
      expect(subject.default_message).to match("check the parsing strategy")
    end
  end
end
