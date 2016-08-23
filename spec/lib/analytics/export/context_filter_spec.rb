require "analytics/export"

describe Analytics::Export::ContextFilter do
  subject { described_class.new course_context }
  let(:course_context) { double(:context, class: "CourseExportContext") }

  before(:each) do
    described_class
      .instance_variable_set :@valid_context_types, [:course_export_context]
  end

  describe "#initialize" do
    it "sets a context" do
      expect(subject.context).to eq course_context
    end

    it "validates the context type" do
      expect_any_instance_of(described_class).to receive(:validate_context_type)
      subject
    end

    it "returns itself" do
      expect(subject.class).to eq described_class
      expect(subject).to eq subject
    end
  end

  describe "#validate_context_type" do
    it "returns true if the context type is valid" do
      allow(subject).to receive(:valid_context_type?) { true }
      expect(subject.validate_context_type).to eq true
    end

    it "raises an error if the context type is invalid" do
      allow(subject).to receive(:valid_context_type?) { false }

      expect { subject.validate_context_type }
        .to raise_error(Analytics::Errors::InvalidContextType)
    end
  end

  describe "#valid_context_type?" do
    it "returns true if the context type is in the valid list" do
      allow(described_class).to receive(:valid_context_types)
        .and_return [:some_context_type, :course_export_context]

      allow(subject).to receive(:context_type) { :some_context_type }

      expect(subject.valid_context_type?).to eq true
    end

    it "returns false if the context type is not in the valid list" do
      allow(described_class).to receive(:valid_context_types)
        .and_return [:some_context_type, :course_export_context]

      allow(subject).to receive(:context_type) { :another_context_type }

      expect(subject.valid_context_type?).to eq false
    end
  end

  describe "#context_type" do
    it "converts the context class to an underscored symbol" do
      # note that we've stubbed the class for the course context double above
      expect(subject.context_type).to eq :course_export_context
    end
  end

  describe ".accepts_context_types" do
  end

  describe ".valid_context_types" do
  end
end
