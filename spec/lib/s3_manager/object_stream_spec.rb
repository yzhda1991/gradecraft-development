require "s3_manager/basics"
require "s3_manager/object_stream"

describe S3Manager::ObjectStream do
  subject { described_class.new object_key: "some-key" }

  describe "#initialize" do
    it "sets the given object_key to @object_key" do
      expect(subject.object_key).to eq "some-key"
    end

    it "won't build without an object_key" do
      expect { described_class.new }.to raise_error(ArgumentError)
    end
  end

  describe "#object" do
  end

  describe "#exists?" do
  end

  describe "#stream!" do
  end
end
