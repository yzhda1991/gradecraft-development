describe Analytics::Errors::InvalidContextType do
  subject do
    described_class.new \
      context_filter: context_filter,
      context_type: "stuff",
      message: "some-message"
  end

  let(:context_filter) { double(:context_filter).as_null_object }

  it "inherits from StandardError" do
    expect(described_class.superclass).to eq StandardError
  end

  describe "#initialize" do
    it "sets a context_filter" do
      expect(subject.context_filter).to eq context_filter
    end

    it "sets a context_type" do
      expect(subject.context_type).to eq "stuff"
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
    it "includes the inspected context filter" do
      expect(subject.default_message)
        .to include(subject.context_filter.inspect)
    end

    it "includes the inspected context type" do
      expect(subject.default_message)
        .to include(subject.context_type.inspect)
    end

    it "has some other snazzy explanation" do
      expect(subject.default_message).to match("only valid context types")
    end
  end
end
