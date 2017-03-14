describe S3Manager::Streaming do
  describe S3ManagerStreamingTest do
    subject { described_class.new }

    let(:object_stream) { double(:object_stream) }

    before do
      allow(subject).to receive(:s3_object_file_key) { "some-key" }
    end

    describe "#object_stream" do
      let(:result) { subject.object_stream }

      it "should build a new ObjectStream with the object_key" do
        expect(S3Manager::ObjectStream).to receive(:new)
          .with({ object_key: "some-key" })
        result
      end

      it "should cache the object_stream" do
        result
        expect(S3Manager::ObjectStream).not_to receive(:new)
        result
      end

      it "should set the object_stream to @object_stream" do
        allow(S3Manager::ObjectStream).to receive(:new) { object_stream }
        result
        expect(subject.instance_variable_get(:@object_stream))
          .to eq object_stream
      end
    end
  end
end
