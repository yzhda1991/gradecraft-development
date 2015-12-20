require 'rails_spec_helper'

include Toolkits::S3Manager::EncryptionToolkit

RSpec.describe S3Manager::ObjectSummary do
  let(:s3_manager) { S3Manager::Manager.new }

  describe "#encrypted_client" do
    subject { s3_manager.encrypted_client }

    it "builds a new encrypted client" do
      expect(subject.class).to eq(Aws::S3::Encryption::Client)
    end

    it "uses a standard s3 client" do
      expect(subject.instance_variable_get(:@client)).to eq(s3_manager.client)
    end

    describe "cipher provider" do
      subject { s3_manager.encrypted_client.instance_variable_get(:@cipher_provider) }

      it "sets the kms_key_id" do
        expect(subject.instance_variable_get(:@kms_key_id)).to eq(s3_manager.kms_key_id)
      end

      it "sets the kms_client" do
        expect(subject.instance_variable_get(:@kms_client)).to eq(s3_manager.kms_client)
      end
    end

    it "caches the encrypted client" do
      subject
      expect(Aws::S3::Encryption::Client).not_to receive(:new)
      subject
    end
  end
end
