describe SecureTokenValidator do
  subject { described_class.new }

  let(:record) do
    # let's start with uuid and encrypted key formats that match the regexes
    double(:record, uuid: "some-uuid", encrypted_key: "some-hex-key",
            errors: { uuid: [], encrypted_key: [] } )
  end

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
  end

  describe "validating attributes" do
    before(:each) { subject.record = record }

    describe "#validate_uuid_format" do
      let(:result) { subject.validate_uuid_format }

      before(:each) do
        allow(SecureTokenValidator::Regex).to receive(:uuid) { regex }
      end

      context "the record's :uuid matches the validator regex" do
        let(:regex) { /some-uuid/ }

        it "returns nil" do
          expect(result).to be_nil
        end

        it "doesn't add an error message for the uuid" do
          result
          expect(record.errors[:uuid]).to be_empty
        end
      end

      context "the record's :uuid does not match the validator regex" do
        let(:regex) { /invalid-uuid-format/ }

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
  end
end
