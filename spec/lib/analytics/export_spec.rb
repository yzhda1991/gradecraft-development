require "./spec/support/test_classes/lib/analytics/analytics_export_test"

describe Analytics::Export do

  # test modular behaviors in the context of a test class
  describe AnalyticsExportTest do
    subject { described_class.new loaded_data }
    let(:loaded_data) { { some: "data" } }

    it "has been extended with Analytics::Export::ClassMethods" do
      expect(described_class).to respond_to :set_schema
      expect(described_class).to respond_to :rows_by
    end

    it "has an accessible data attribute" do
      subject.data = "some data"
      expect(subject.data).to eq "some data"
    end

    it "sets the loaded data to data on #initialize" do
      expect(subject.data).to eq loaded_data
    end

    describe "#records" do
      let(:loaded_data) { { fossils: ["travis"] } }

      it "selects the data value using the key set in rows_by" do
        expect(subject.records).to eq ["travis"]
      end

      it "caches the records" do
        subject.records
        expect(subject.data).not_to receive(:[]).with :fossils
        subject.records
      end
    end
  end
end
