require "analytics/export"
require "./spec/support/test_classes/lib/analytics/analytics_export_model_test"
require "./spec/support/test_classes/lib/analytics/export/test_context_filter"

describe Analytics::Export::Model do
  subject { described_class.new context: context }
  let(:context) { double(:context, class: "TestContext").as_null_object }

  describe "#column_mapping" do
    it "sets the column mapping for the class" do
      described_class.column_mapping({ some: :columns })
      expect(described_class.instance_variable_get :@column_mapping)
        .to eq({ some: :columns })
    end
  end

  describe "#export_focus" do
    it "sets the name of the context method to use for the export records" do
      described_class.export_focus :some_focus
      expect(described_class.instance_variable_get :@export_focus)
        .to eq :some_focus
    end
  end

  describe "#context_filters" do
    it "sets a list of context filters to build for the export" do
      described_class.context_filters :some_filter, :another_filter
      expect(described_class.instance_variable_get :@context_filters)
        .to eq [:some_filter, :another_filter]
    end
  end

  describe "#initialize" do
    it "sets the context" do
      expect(subject.context).to eq context
    end

    it "sets an optional filename" do
      model = described_class.new context: context, filename: "something.csv"
      expect(model.filename).to eq "something.csv"
    end

    it "derives the export_focus from the class" do
      described_class.export_focus :some_focus
      expect(subject.export_focus).to eq :some_focus
    end

    it "derives the column_mapping from the class" do
      described_class.column_mapping({ the: "mapping" })
      expect(subject.column_mapping).to eq({ the: "mapping" })
    end

    it "gets the export records from the context using the export_focus" do
      described_class.export_focus :some_focus
      allow(context).to receive(:some_focus) { ["the", "records"] }
      expect(subject.export_records).to eq  ["the", "records"]
    end
  end

  describe "#parsed_columns" do
    it "builds a column parser and uses it" do
      allow_any_instance_of(Analytics::Export::Parsers::Column).to receive(:parse!)
        .and_return({ some: ["columns"] })

      expect(subject.parsed_columns).to eq({ some: ["columns"] })
    end
  end

  describe "#parsed_rows" do
    it "returns nil if there aren't any columns" do
      allow(subject).to receive(:parsed_columns) { nil }
      expect(subject.parsed_columns).to be_nil
    end

    it "transposes the columns into rows if columns exist" do
      allow(subject).to receive(:parsed_columns).and_return({
        column_a: %w[a b c],
        column_b: [1, 2, 3]
      })

      expect(subject.parsed_rows).to eq \
        [["a", 1], ["b", 2], ["c", 3]]
    end
  end

  describe "#column_names" do
    it "returns the keys from the column mapping if there is one" do
      allow(subject).to receive(:column_mapping).and_return(
        { some_column: [], another_column: [] }
      )

      expect(subject.column_names).to eq [:some_column, :another_column]
    end

    it "returns nil if no column_mapping is present" do
      allow(subject).to receive(:column_mapping) { nil }
      expect(subject.column_names).to be_nil
    end
  end

  describe "#default_filename" do
    it "builds a filename from the class name" do
      expect(subject.default_filename).to eq "analytics_export_model.csv"
    end
  end

  describe "#context_filters" do
    it "builds an array of context filter instances" do
      described_class.context_filters :test
      TestContextFilter.accepts_context_types :test_context

      expect(subject.context_filters[:test].class)
        .to eq TestContextFilter
    end
  end

  describe "#write_csv" do
    it "writes the actual CSV file" do
      tmpdir = Dir.mktmpdir
      allow(subject).to receive_messages \
        column_names: [:first, :second],
        parsed_rows: [%w[a b], %w[c d]],
        filename: "some_filename.csv"

      csv = subject.write_csv tmpdir

      filepath = File.join tmpdir, "some_filename.csv"
      rows = CSV.read filepath

      expect(rows.first).to eq %w[first second]
      expect(rows[1]).to eq %w[a b]
      expect(rows.last).to eq %w[c d]
    end
  end
end
