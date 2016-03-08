require "rails_spec_helper"

RSpec.describe S3Manager::Resource do
  subject { S3ResourceTest.new }
  let(:s3_manager) { double(S3Manager::Manager) }
  let(:s3_object_key) { double(:s3_object_key) }

  describe "#presigned_s3_url" do
    before { subject.s3_object_key = "some-test-key" }

    it "gets the presigned url for the s3 object" do
      expect(subject.s3_manager).to receive_message_chain(
        :bucket, :object, :presigned_url, :to_s)
      subject.presigned_s3_url
    end
  end

  describe "#s3_manager" do
    let(:result) { subject.s3_manager }

    it "builds a new S3Manager::Manager object" do
      expect(S3Manager::Manager).to receive(:new)
      result
    end

    it "caches the object" do
      result
      expect(S3Manager::Manager).not_to receive(:new)
      result
    end

    it "sets the S3Manager object to @s3_manager" do
      allow(S3Manager::Manager).to receive(:new) { s3_manager }
      expect(result).to eq s3_manager
    end
  end

  describe "#upload_file_to_s3" do
    let(:result) { subject.upload_file_to_s3("great-file.txt") }

    before do
      allow(s3_manager).to receive(:put_encrypted_object) { "some s3 response" }
      allow(subject).to receive(:s3_object_key) { "snake-hat-key" }
      allow(subject).to receive(:s3_manager) { s3_manager }
    end

    it "puts an S3 encrypted object with the object key and file path" do
      expect(s3_manager).to receive(:put_encrypted_object)
        .with("snake-hat-key", "great-file.txt")
      result
    end

    it "returns the response from the S3 manager" do
      expect(result).to eq("some s3 response")
    end
  end

  describe "#s3_object_summary" do
    let(:result) { subject.s3_object_summary }

    before do
      allow(subject).to receive_messages(
        s3_object_key: s3_object_key, s3_manager: s3_manager
      )
    end

    it "builds a new object summary with the object key and the s3 manager" do
      expect(S3Manager::Manager::ObjectSummary).to receive(:new)
        .with(s3_object_key, s3_manager)
      result
    end

    it "returns an ObjectSummary object" do
      expect(result.class).to eq(S3Manager::Manager::ObjectSummary)
    end

    it "caches the new object summary" do
      result
      expect(S3Manager::Manager::ObjectSummary).not_to receive(:new)
      result
    end
  end
end
