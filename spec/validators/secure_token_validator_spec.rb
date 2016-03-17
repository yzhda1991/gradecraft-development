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
  end

  describe "#validate_encrypted_key_format" do
  end
end
