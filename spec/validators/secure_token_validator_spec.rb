require 'active_model'
require_relative "../../app/validators/secure_token_validator"

describe SecureTokenValidator do
  subject { described_class.new }

  let(:record) do
    double(:record, uuid: nil, encrypted_key: nil, errors: errors)
  end
  let(:errors) { { uuid: [], encrypted_key: [] } }

  it "has an accessible record" do
    subject.record = record
    expect(subject.record).to eq record
  end

  describe "#validate" do
    let(:result) { subject.validate record }

    it "sets the record" do
      result
      expect(subject.record).to eq record
    end

    it "validates the uuid format" do
      expect(subject).to receive(:validate_uuid_format)
      result
    end

    it "validates the encrypted key format" do
      expect(subject).to receive(:validate_encrypted_key_format)
      result
    end
  end

  describe "#validate_uuid_format" do
    let(:result) { subject.validate_uuid_format }

    before(:each) do
      subject.record = record
    end

    context "the record's :uuid matches the validator regex" do
      before(:each) do
        allow(subject.record).to receive(:uuid) { SecureRandom.uuid }
      end

      it "returns nil" do
        expect(result).to be_nil
      end

      it "doesn't add an error message for the uuid" do
        result
        expect(record.errors[:uuid]).to be_empty
      end
    end

    context "the record's :uuid does not match the validator regex" do
      before(:each) do
        allow(subject.record).to receive(:uuid) { "not-the-uuid-format" }
      end

      it "returns the uuid errors array" do
        expect(result).to eq record.errors[:uuid]
      end

      it "inserts an error message into errors[:uuid]" do
        result
        expect(record.errors[:uuid].last).to match "is not valid"
      end

    end
  end

  describe "#validate_encrypted_key_format" do
    context "the record's :encrypted_key matches the validator regex" do
      it "returns nil" do
      end
    end

    context "the record's :encrypted_key does not match the validator regex" do
      it "inserts an error message into errors[:encrypted_key]" do
      end
    end
  end
end
