require "s3_manager/basics"
require "s3_manager/object_stream"

describe S3Manager::ObjectStream do
  subject { described_class.new object_key: "some-key" }

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
    it "gets the object with the object_key" do
    end

    it "caches the object" do
    end

    it "sets the object to @object" do
    end
  end

  describe "#exists?" do
    context "the object doesn't exist" do
      it "returns false" do
      end
    end

    context "the object exists" do
      context "the object has no body" do
        it "returns false" do
        end
      end

      context "the object has a body" do
        it "returns true" do
        end
      end
    end

  end

  describe "#stream!" do
    context "the target object exists on S3" do
      it "reads the body from the object" do
      end
    end

    context "the object does not exist on S3" do
      it "returns false" do
      end
    end
  end
end
