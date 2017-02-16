require "spec_helper"

RSpec.describe S3Manager::Kms do
  let(:s3_manager) { S3Manager::Manager.new }

  describe "#kms_client" do
    subject { s3_manager.kms_client }

    it "builds a new kms client" do
      expect(subject.class).to eq(Aws::KMS::Client)
    end

    it "uses the Seahorse::Model API" do
      expect(subject.config.api.class).to eq(Seahorse::Model::Api)
    end

    it "caches the kms client" do
      subject
      expect(Aws::KMS::Client).not_to receive(:new)
      subject
    end
  end

  describe "#kms_key_id" do
    let(:kms_client) { s3_manager.kms_client }
    subject { s3_manager.kms_key_id }

    it "uses the AWS kms_key_id" do
      expect(subject).to eq(ENV["AWS_KMS_KEY_ID"])
    end

    it "should have 36 characters" do
      expect(subject.size).to eq(36)
    end

    it "should be a string of alphanum characters and hyphens" do
      expect(subject).to match(/[a-z0-9\-]{36}/)
    end

    it "caches the kms_key_id" do
      subject
      expect(kms_client).not_to receive(:create_key)
      subject
    end
  end
end
