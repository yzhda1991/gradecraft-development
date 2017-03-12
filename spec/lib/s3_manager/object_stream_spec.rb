describe S3Manager::ObjectStream do
  subject { described_class.new object_key: "some-key" }
  let(:object) { double(:s3_object, body: object_body) }
  let(:object_body) { double(:object_body, read: "object-content") }

  before do
    allow(subject).to receive(:get_object).with(subject.object_key) { object }
  end

  it "includes S3Manager::Basics" do
    expect(subject).to respond_to(:write_s3_object_to_disk)
  end

  describe "#initialize" do
    it "sets the given object_key to @object_key" do
      expect(subject.object_key).to eq "some-key"
    end

    it "won't build without an object_key" do
      expect { described_class.new }.to raise_error(ArgumentError)
    end
  end

  describe "#object" do
    let(:result) { subject.object }

    it "gets the object with the object_key" do
      expect(subject).to receive(:get_object).with subject.object_key
      result
    end

    it "caches the object" do
      result
      expect(subject).not_to receive(:get_object)
      result
    end

    it "sets the object to @object" do
      result
      expect(subject.instance_variable_get(:@object)).to eq object
    end
  end

  describe "#exists?" do
    let(:result) { subject.exists? }

    context "the object doesn't exist" do
      let(:object) { nil }

      it "returns false" do
        expect(result).to eq false
      end
    end

    context "the object exists" do
      context "the object has no body" do
        it "returns false" do
          allow(object).to receive(:body) { nil }
          expect(result).to eq false
        end
      end

      context "the object has a body" do
        it "returns true" do
          expect(result).to eq true
        end
      end
    end

  end

  describe "#stream!" do
    let(:result) { subject.stream! }

    context "the target object exists on S3" do
      it "reads the body from the object" do
        # note that this is defined in the object_body double
        expect(result).to eq "object-content"
      end
    end

    context "the object does not exist on S3" do
      it "returns false" do
        allow(subject).to receive(:exists?) { false }
        expect(result).to eq false
      end
    end
  end
end
