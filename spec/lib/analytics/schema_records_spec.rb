require "analytics/export/schema_records"

describe Analytics::Export::SchemaRecords do
  subject { described_class.new export: export, records: records }
  let(:export) { double(:export).as_null_object }
  let(:records) { [{ id: 1 }, { id: 2 }] }

  describe "readable attributes" do
    it "has a readable export" do
      expect(subject.export).to eq export
    end

    it "has readable records" do
      expect(subject.records).to eq records
    end
  end

  describe "#initialize" do
    it "sets the export" do
      expect(subject.instance_variable_get(:@export)).to eq export
    end

    it "sets the records" do
      expect(subject.instance_variable_get(:@records)).to eq records
    end
  end

  describe "#schema" do
    it "gets the schema from the export class" do
      expect(subject.export).to receive_message_chain(:class, :schema)
      subject.schema
    end
  end

  describe "#progress_message" do
    it "returns a message about the progress of the export" do
      # let's presume there are a hundred records
      allow(subject).to receive(:records) { (1..100).collect }

      expect(subject.progress_message record_number: 50).to include \
        "record 50 of 100 (50%)"
    end
  end

  describe "#total_records" do
    it "gets the size of the records array" do
      expect(subject.total_records).to eq records.size
    end

    it "caches the size" do
      subject.total_records
      expect(subject.records).not_to receive(:size)
      subject.total_records
    end
  end

  describe "#messageable_record?" do
    # let's say there are 40 records for the purpose of testing these examples
    let(:records) { (1..40).collect }

    context "record_number is divisible by five" do
      it "returns true" do
        expect(subject.messageable_record? record_number: 10).to eq true
      end
    end

    context "record_number is larger than the total record size" do
      it "returns false" do
        expect(subject.messageable_record? record_number: 93).to eq false
        expect(subject.messageable_record? record_number: 45).to eq false
      end
    end

    context "record_number is not divisible by five" do
      context "the record_number is for last record in #total_records" do
        it "returns true" do
          expect(subject.messageable_record? record_number: 40).to eq true
        end
      end

      context "the record_number is not for the last record" do
        it "returns false" do
          expect(subject.messageable_record? record_number: 34).to eq false
        end
      end
    end
  end
end
