require "analytics/export"
require "./spec/support/test_classes/lib/analytics/analytics_export_model_test"

describe Analytics::Export::Model do
  subject { described_class.new context: context }
  let(:context) { double(:context).as_null_object }

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
end
