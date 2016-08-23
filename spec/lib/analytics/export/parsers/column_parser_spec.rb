require "analytics/export/parsers"
require "./spec/support/test_classes/lib/analytics/analytics_export_model_test"

describe Analytics::Export::Parsers::Column do
  subject { described_class.new export }
  let(:export) { AnalyticsExportModelTest.new context: course_context }
  let(:course_context) { double(:context) }
  let(:records) { [{ id: 1 }, { id: 2 }] }

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
end
