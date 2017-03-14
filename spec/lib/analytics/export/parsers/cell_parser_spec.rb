describe Analytics::Export::Parsers::Cell do
  subject do
    described_class.new \
      parsing_strategy: :some_strategy,
      record: some_record,
      export: some_export
  end

  let(:some_record) { double :record }
  let(:some_export) { double :export }

  describe "#initialize" do
    it "sets a parsing strategy" do
      expect(subject.parsing_strategy).to eq :some_strategy
    end

    it "sets a record" do
      expect(subject.record).to eq some_record
    end

    it "sets an export" do
      expect(subject.export).to eq some_export
    end
  end

  describe "#parsed_value" do
    it "calls the strategy on the export if the export responds to it" do
      allow(some_export).to receive(:some_strategy) { 20 }
      expect(subject.parsed_value).to eq 20
    end

    it "calls the strategy on the record if the record responds to it" do
      allow(some_record).to receive(:some_strategy) { 40 }
      expect(subject.parsed_value).to eq 40
    end

    it "raises an error if neither the error nor the record responds" do
      expect { subject.parsed_value }
        .to raise_error Analytics::Errors::InvalidParsingStrategy
    end
  end

  describe "#record_strategy" do
    it "sends the parsing strategy to the record and returns the result" do
      allow(subject).to receive(:parsing_strategy) { :another_strategy }
      allow(some_record).to receive(:another_strategy) { "some value" }
      expect(subject.record_strategy).to eq "some value"
    end
  end

  describe "#export_strategy" do
    it "sends the parsing strategy to the export and returns the result" do
      allow(subject).to receive(:parsing_strategy) { :another_strategy }
      allow(some_export).to receive(:another_strategy)
        .with(some_record) { "another value" }

      expect(subject.export_strategy).to eq "another value"
    end
  end
end
