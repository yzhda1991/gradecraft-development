require 'rails_spec_helper'

include Toolkits::S3Manager::EncryptionToolkit

RSpec.describe S3Manager::Encryption do
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

  describe "managing client-encrypted objects" do
    let(:object_key) { "jerrys-hat" }
    let(:object_body) { "jerry was here." }
    let(:encrypted_client) { s3_manager.encrypted_client }

    describe "#put_encrypted_object" do
      subject { s3_manager.put_encrypted_object(object_key, object_body) }

      it "should call #put_object on the encrypted client" do
        expect(encrypted_client).to receive(:put_object)
        subject
      end

      it "should get an AWS Seahorse object in response" do
        expect(subject.class).to eq(Seahorse::Client::Response)
      end

      it "should have been sucessful" do
        expect(subject.successful?).to be_truthy
      end

      it "should suggest that AES256 encryption was used" do
        expect(subject.server_side_encryption).to eq("AES256")
      end
    end

    describe "#get_encrypted_object" do
      subject { s3_manager.get_encrypted_object(object_key) }

      it "should call #get_object on the encrypted client" do
        expect(encrypted_client).to receive(:get_object)
        subject
      end

      it "should get an AWS Seahorse object in response" do
        expect(subject.class).to eq(Seahorse::Client::Response)
      end
      
      it "should have been sucessful" do
        expect(subject.successful?).to be_truthy
      end

      it "should have the correct body of the gotten object" do
        expect(subject.body.read).to eq(object_body)
      end

      it "should suggest that AES256 encryption was used" do
        expect(subject.server_side_encryption).to eq("AES256")
      end
    end
  end
end
