require "analytics/export/parsers"
require "./spec/support/test_classes/lib/analytics/analytics_export_model_test"

describe Analytics::Export::Parsers::Column do
  subject { described_class.new export }
  let(:export) { AnalyticsExportModelTest.new context: course_context }
  let(:course_context) { double(:context) }

  let(:some_record) { double :record, albatross: 20, badger: 90 }
  let(:another_record) { double :record, albatross: 40, badger: 300 }
  let(:records) { [some_record, another_record] }

  before do
    allow(export).to receive(:export_records) { records }
  end

  describe "#initialize" do
    it "sets the export" do
      expect(subject.instance_variable_get(:@export)).to eq export
    end

    it "sets the records" do
      expect(subject.instance_variable_get(:@records)).to eq records
    end

    it "sets the parsed_columns" do
      allow_any_instance_of(described_class).to receive(:build_default_columns)
        .and_return({ some: [], columns: [] })

      expect(subject.instance_variable_get(:@parsed_columns))
        .to eq({ some: [], columns: [] })
    end
  end

  describe "#build_default_columns" do
    it "returns nil if the export doesn't have any column names" do
      allow(export).to receive(:column_names) { nil }
      expect(subject.build_default_columns).to be_nil
    end
  end

  describe "#parse!" do
    it "parses a cell for each record defined in the column mapping" do
      allow(export).to receive(:column_mapping) \
        { { albatross_info: :albatross, badger_info: :badger } }

      subject.parse!
      expect(subject.parsed_columns[:albatross_info]).to eq [20, 40]
      expect(subject.parsed_columns[:badger_info]).to eq [90, 300]
    end
  end

  describe "#progress_message" do
    it "builds a progress message" do
      expect(Analytics::Export::ProgressMessage).to receive(:new)
        .with({
          record_index: 3,
          total_records: 4,
          print_every: 5
        })

      allow(subject).to receive(:records)
        .and_return double(:records, size: 4)

      subject.progress_message 3
    end
  end
end
